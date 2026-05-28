# Claude Code 任务栏闪烁

当 Claude Code 需要你关注时（弹出选项、权限请求、任务完成），让 Windows 任务栏图标闪烁提醒。

## 这是什么

当你切到其他窗口后，终端任务栏图标会在以下情况闪烁：

- Claude 问你问题（AskUserQuestion）
- Claude 弹出权限请求（PermissionRequest）
- Claude 完成任务（Stop）

切回终端后闪烁自动停止。闪烁机制：先快速闪烁 3 次引起注意，若仍未切回则保持高亮状态，直到你切回终端。

## 支持的平台

| 平台 | 状态 |
|----------|--------|
| Windows (Windows Terminal) | 已支持 |
| macOS | 计划中 |
| Linux | 计划中 |

## 快速安装

### 1. 添加市场源（仅首次）

```
/plugin marketplace add zhangshaoyi979/claude-taskbar-flash
```

### 2. 安装插件

```
/plugin install taskbar-flash@zhangshaoyi979-taskbar-flash
```

### 3. 运行配置

直接说：**"setup taskbar flash"**，Claude 会自动完成配置。

### 4. 重启 Claude Code

按 `Ctrl+C` 退出，重新运行 `claude`。

## 手动安装（不使用插件）

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
    "allow": ["Bash(powershell *)"]
  }
}
```

3. 重启 Claude Code

## 卸载

从 `~/.claude/settings.json` 中移除 hooks 配置，并删除 `~/.claude/flash-taskbar.ps1`。

## 原理

`flash-taskbar.ps1` 调用 Windows `FlashWindowEx` API：

- 通过进程树定位终端窗口，适配 Windows Terminal、CMD、PowerShell 等多种终端
- 终端在前台时自动跳过，不打扰
- 先闪烁 3 次引起注意，若仍未切回则保持任务栏高亮

## 协议

MIT
