# AGENTS.md

## 可用代理

### 基础代理
- **gateway**: 主要网关，处理消息路由和调度
- **telegram**: Telegram消息通道代理

### 工具代理
- **openclaw**: 核心OpenClaw代理，执行命令和工具调用

## 配置

默认配置已通过Nix设置，包含：
- Telegram通道配置
- 本地网关模式
- 认证令牌

如需添加新代理，请参考OpenClaw文档。