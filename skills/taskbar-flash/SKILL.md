---
name: taskbar-flash
description: Setup taskbar flashing on Windows so Claude Code alerts you when it needs your attention (permission prompts, questions, task completion). macOS/Linux coming soon.
---

# Taskbar Flash Setup

This skill configures Claude Code to flash the Windows taskbar when:
- A permission prompt appears
- Claude asks you a question
- Claude finishes a task

## Usage

Just say "setup taskbar flash" or "configure taskbar notification" — Claude will follow this guide automatically.

## Setup Instructions for Claude

When asked to set up taskbar flash, follow these steps:

### Step 1: Detect OS

Run `echo "$OSTYPE"` (bash) or check if Windows. **Windows only** for now. On macOS/Linux, say "macOS/Linux support is not yet available — only Windows is supported. Would you like to contribute?"

### Step 2: Copy the flashing script (Windows)

Copy the bundled PowerShell script to `~/.claude/`:

```
cp "<plugin_root>/skills/taskbar-flash/scripts/flash-taskbar.ps1" ~/.claude/flash-taskbar.ps1
```

`<plugin_root>` is the directory containing `.claude-plugin/plugin.json`. Use the actual path from the environment.

### Step 3: Configure hooks (Windows)

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
          "command": "powershell -ExecutionPolicy Bypass -File \"$HOME/.claude/flash-taskbar.ps1\""
        }]
      }
    ],
    "PermissionRequest": [
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": "powershell -ExecutionPolicy Bypass -File \"$HOME/.claude/flash-taskbar.ps1\""
        }]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": "powershell -ExecutionPolicy Bypass -File \"$HOME/.claude/flash-taskbar.ps1\""
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
- "Configuration saved. Restart Claude Code for the hooks to take effect."
- "To test: switch away from the terminal and wait — the taskbar will flash when Claude asks a question or finishes responding."
- "To uninstall: remove the hooks from ~/.claude/settings.json and delete ~/.claude/flash-taskbar.ps1"

## Cross-Platform Design Notes

When adding macOS/Linux support:
- macOS: use `osascript -e 'display notification ...'` for notifications, or bounce the Dock icon via `osascript -e 'tell app "Terminal" to activate'`
- Linux: use `notify-send` or `zenity` for desktop notifications
- The SKILL.md Step 2-3 should branch by OS
- Add platform-specific scripts under `scripts/macos/` and `scripts/linux/`
- The hooks `command` field should use OS-appropriate commands
