# Claude Code Taskbar Flash / Claude Code 任务栏闪烁

Flash the Windows taskbar when Claude Code needs your attention.

当 Claude Code 需要你关注时（弹出选项、权限请求、任务完成），让 Windows 任务栏图标闪烁提醒。

---

## 这是什么 / What it does

When Claude Code is running and you switch to another window, the terminal taskbar icon will flash when:
- Claude asks you a question (AskUserQuestion)
- Claude shows a permission prompt (PermissionRequest)
- Claude finishes a task (Stop)

The flashing stops automatically when you switch back to the terminal.

当你切到其他窗口后，终端任务栏图标会在以下情况闪烁：
- Claude 问你问题
- Claude 弹出权限请求
- Claude 完成任务

切回终端后闪烁自动停止。

---

## 支持的平台 / Supported Platforms

| 平台 / Platform | 状态 / Status |
|----------|--------|
| Windows (Windows Terminal) | 已支持 / Supported |
| macOS | 计划中 / Planned |
| Linux | 计划中 / Planned |

---

## 快速安装 / Quick Install

### 1. 添加市场源（仅首次）/ Add marketplace (one-time)
```
/plugin marketplace add zhangshaoyi979/claude-taskbar-flash
```

### 2. 安装插件 / Install the plugin
```
/plugin install taskbar-flash@zhangshaoyi979-taskbar-flash
```

### 3. 运行配置 / Run setup
Just say: **"setup taskbar flash"**

直接说：**"setup taskbar flash"**，Claude 会自动完成配置。

### 4. 重启 Claude Code / Restart Claude Code
Press `Ctrl+C` and restart `claude`.

---

## 手动安装（不使用插件）/ Manual Setup (without plugin)

1. 复制 `skills/taskbar-flash/scripts/flash-taskbar.ps1` 到 `~/.claude/`
2. 在 `~/.claude/settings.json` 中添加以下配置：

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
  },
  "permissions": {
    "allow": ["Bash(powershell * )"]
  }
}
```

3. 重启 Claude Code

---

## 卸载 / Uninstall

Remove the hooks from `~/.claude/settings.json` and delete `~/.claude/flash-taskbar.ps1`.

从 `~/.claude/settings.json` 中移除 hooks 配置，并删除 `~/.claude/flash-taskbar.ps1`。

---

## 原理 / How it works

`flash-taskbar.ps1` calls the Windows `FlashWindowEx` API:
- 闪烁 3 次引起注意，若仍未切回则保持高亮
- 通过进程树定位终端窗口，适配多种终端
- 终端在前台时自动跳过，不打扰

---

## 协议 / License

MIT
