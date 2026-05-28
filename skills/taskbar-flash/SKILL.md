---
name: taskbar-flash
description: Setup, update, or uninstall taskbar flashing on Windows so Claude Code alerts you when it needs your attention (permission prompts, questions, task completion).
---

# Taskbar Flash

This skill manages Claude Code taskbar flashing for Windows. Supports three operations: setup, update, and uninstall.

## Usage

- `/taskbar-flash` or "setup taskbar flash" — first-time setup
- "update taskbar flash" or "升级任务栏闪烁" — update the script to latest version
- "uninstall taskbar flash" or "卸载任务栏闪烁" — remove everything

## Operation: Setup (default)

When asked to set up taskbar flash, follow these steps:

### Step 0: Check if already configured

Check if `~/.claude/flash-taskbar.ps1` exists AND `~/.claude/settings.json` contains the three hooks (PreToolUse with AskUserQuestion matcher, PermissionRequest, Stop) referencing `flash-taskbar.ps1`.

If already fully configured, tell the user: "任务栏闪烁已配置，无需重复安装。如需更新脚本请说 'update'，如需卸载请说 'uninstall'。" Stop here — do not proceed to Step 1.

If the script exists but some hooks are missing, proceed to Step 1 and repair the missing hooks.

### Step 1: Detect OS

Run `echo "$OSTYPE"` (bash) or check if Windows. **Windows only** for now. On macOS/Linux, say "macOS/Linux 暂不支持，目前仅支持 Windows。"

### Step 2: Copy the flashing script

Copy the bundled PowerShell script to `~/.claude/`:

```
cp "<plugin_root>/skills/taskbar-flash/scripts/flash-taskbar.ps1" ~/.claude/flash-taskbar.ps1
```

`<plugin_root>` is the directory containing `.claude-plugin/plugin.json`. Use the actual path from the environment.

### Step 3: Configure hooks

Read `~/.claude/settings.json`. Merge the following hooks into the `"hooks"` key. If the key doesn't exist, create it. If individual hooks already exist, skip them (don't duplicate).

**Hooks to add:**

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "AskUserQuestion",
        "hooks": [{
          "type": "command",
          "command": "powershell -ExecutionPolicy Bypass -File \"$HOME/.claude/flash-taskbar.ps1\"",
          "async": true
        }]
      }
    ],
    "PermissionRequest": [
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": "powershell -ExecutionPolicy Bypass -File \"$HOME/.claude/flash-taskbar.ps1\"",
          "async": true
        }]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": "powershell -ExecutionPolicy Bypass -File \"$HOME/.claude/flash-taskbar.ps1\"",
          "async": true
        }]
      }
    ]
  }
}
```

**Permission to add** (if not already present):

```json
"Bash(powershell *)"
```

Add it to `permissions.allow` array in `~/.claude/settings.json`.

### Step 4: Confirm

Tell the user:
- "配置已保存。重启 Claude Code 后生效。"
- "测试方法：切到其他窗口，当 Claude 提问或完成任务时任务栏会闪烁。"
- "更新：/taskbar-flash 后说 'update'。卸载：说 'uninstall taskbar flash'。"

## Operation: Update

When the user asks to update the taskbar flash script:

1. Check OS — Windows only.
2. Copy the latest script from `<plugin_root>/skills/taskbar-flash/scripts/flash-taskbar.ps1` to `~/.claude/flash-taskbar.ps1`, overwriting the old one.
3. Read `~/.claude/settings.json` and verify the three hooks (PreToolUse/AskUserQuestion, PermissionRequest, Stop) and the `Bash(powershell *)` permission still exist. If any are missing, re-add them.
4. Tell the user: "脚本已更新到最新版本，无需重启，下次触发时自动生效。"

## Operation: Uninstall

When the user asks to uninstall taskbar flash:

1. Read `~/.claude/settings.json`.
2. Remove the three hook entries from `"hooks"`:
   - The `PreToolUse` entry with `"matcher": "AskUserQuestion"` whose command references `flash-taskbar.ps1`
   - The `PermissionRequest` entry whose command references `flash-taskbar.ps1`
   - The `Stop` entry whose command references `flash-taskbar.ps1`
3. If a hook key (PreToolUse/PermissionRequest/Stop) has an empty array after removal, remove the key entirely.
4. Remove `"Bash(powershell *)"` from `permissions.allow` if present.
5. Delete `~/.claude/flash-taskbar.ps1`.
6. Tell the user: "已卸载。hooks 配置和脚本均已移除。重启 Claude Code 后生效。"

## Cross-Platform Design Notes

When adding macOS/Linux support:
- macOS: use `osascript -e 'display notification ...'` for notifications, or bounce the Dock icon via `osascript -e 'tell app "Terminal" to activate'`
- Linux: use `notify-send` or `zenity` for desktop notifications
- The SKILL.md operations should branch by OS
- Add platform-specific scripts under `scripts/macos/` and `scripts/linux/`
- The hooks `command` field should use OS-appropriate commands
