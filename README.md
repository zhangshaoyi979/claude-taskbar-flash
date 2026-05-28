# Claude Code Taskbar Flash

Flash the Windows taskbar when Claude Code needs your attention.

## What it does

When Claude Code is running and you switch to another window, the terminal taskbar icon will flash **continuously** when:
- Claude asks you a question (AskUserQuestion)
- Claude shows a permission prompt (PermissionRequest)  
- Claude finishes a task (Stop)

The flashing stops automatically when you switch back to the terminal.

## Supported Platforms

| Platform | Status |
|----------|--------|
| Windows (Windows Terminal) | Supported |
| macOS | Planned |
| Linux | Planned |

## Quick Install

### 1. Add the marketplace (one-time)
```
/plugin marketplace add <your-github>/claude-taskbar-flash
```

### 2. Install the plugin
```
/plugin install taskbar-flash@<your-github>-taskbar-flash
```

### 3. Run setup
Just say: **"setup taskbar flash"**

Claude will automatically copy the script and configure hooks.

### 4. Restart Claude Code
Press `Ctrl+C` and restart `claude`.

## Manual Setup (without plugin)

1. Copy `skills/taskbar-flash/scripts/flash-taskbar.ps1` to `~/.claude/`
2. Add the following to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "AskUserQuestion",
        "hooks": [{"type": "command", "command": "powershell -ExecutionPolicy Bypass -File \"$HOME/.claude/flash-taskbar.ps1\""}]
      }
    ],
    "PermissionRequest": [
      {
        "matcher": "",
        "hooks": [{"type": "command", "command": "powershell -ExecutionPolicy Bypass -File \"$HOME/.claude/flash-taskbar.ps1\""}]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [{"type": "command", "command": "powershell -ExecutionPolicy Bypass -File \"$HOME/.claude/flash-taskbar.ps1\""}]
      }
    ]
  },
  "permissions": {
    "allow": ["Bash(powershell *)"]
  }
}
```

3. Restart Claude Code

## Uninstall

Remove the hooks from `~/.claude/settings.json` and delete `~/.claude/flash-taskbar.ps1`.

## How it works

`flash-taskbar.ps1` calls the Windows `FlashWindowEx` API with `FLASHW_TRAY | FLASHW_TIMERNOFG`:
- Finds the terminal window by walking the process tree
- Skips flashing if the terminal is already in the foreground
- Flashes continuously until you switch back, then stops automatically

## License

MIT
