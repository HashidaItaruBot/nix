# TOOLS.md

## 可用工具

### 系统工具
- **命令行访问**：执行shell命令
- **文件操作**：浏览、创建、编辑文件
- **进程管理**：查看和管理运行中的进程

### 内置工具（通过nix-openclaw）
- **summarize**：总结网页、PDF、视频内容
- **peekaboo**：截图功能（macOS）
- **oracle**：网络搜索
- **其他工具**：根据插件配置启用

## 工具使用指南

### 基本命令
```
/help - 显示帮助信息
/tools - 列出可用工具
/status - 检查系统状态
```

### 安全注意事项
1. 我只会在你的授权下执行命令
2. 危险操作需要明确确认
3. 所有操作都有日志记录

## 添加新工具

通过Nix配置添加插件：
```nix
plugins = [
  { source = "github:owner/tool-plugin"; }
];
```

运行 `home-manager switch` 后新工具将自动可用。