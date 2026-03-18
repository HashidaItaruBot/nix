# 外部集成

## 概述

本项目集成了多个外部服务和 API，主要通过 sops-nix 进行密钥管理。

## API 密钥管理

### 存储位置

- `shared/secrets/mihomo_config.yaml` - Mihomo 代理配置
- `shared/secrets/api_keys.yaml` - API 密钥存储
- `shared/secrets/telegram_bot_token.yaml` - Telegram Bot Token

### 环境变量注入

通过 `shared/system/sops.nix` 配置：

```nix
environment.extraInit = ''
  export DEEPSEEK_API_KEY="$(cat ${config.sops.secrets.deepseek_api_key.path})"
  export ALIBABA_API_KEY="$(cat ${config.sops.secrets.alibaba_api_key.path})"
  export ANTHROPIC_AUTH_TOKEN=$ALIBABA_API_KEY
  export ANTHROPIC_BASE_URL="https://coding.dashscope.aliyuncs.com/apps/anthropic"
  export ANTHROPIC_MODEL="glm-5"
  export TELEGRAM_BOT_TOKEN=$(cat ${config.sops.secrets.telegram_bot_token.path})
'';
```

## 集成的外部服务

### AI 服务

| 服务 | 用途 | 环境变量 |
|------|------|----------|
| **DeepSeek** | AI API | `DEEPSEEK_API_KEY` |
| **Alibaba/Qwen** | AI API | `ALIBABA_API_KEY` |
| **Anthropic (代理)** | Claude API 兼容 | `ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_BASE_URL` |

### 代理服务

| 服务 | 状态 | 配置 |
|------|------|------|
| **Mihomo** | 可选启用 | TUN 模式, WebUI |

### 通讯服务

| 服务 | 用途 |
|------|------|
| **Telegram Bot** | Bot API |

### 网络服务

| 服务 | 用途 |
|------|------|
| **ZeroTier** | VPN 组网 |
| **Sunshine** | 游戏串流服务 |

### 开发服务

| 服务 | 用途 |
|------|------|
| **GitHub** | 通过 `gh` CLI |
| **SSH** | GitHub SSH 密钥转发 |

## 云服务集成

### NixOS

- **NTP 服务器**: 阿里云 NTP, 清华大学 NTP
- **Steam**: 远程串流端口开放
- **Proton**: Proton-GE 兼容层

### macOS

- Homebrew 自动更新和清理
- Mac App Store (`mas`)

## 密钥管理流程

1. 使用 sops-nix 加密敏感信息
2. 通过 SSH 密钥派生 AGE 密钥
3. 构建时自动解密到指定路径
4. 通过环境变量注入应用

## Git 集成

### 配置文件

- `shared/home/git.nix` - 共享 Git 配置
- `nixos/home/git.nix` - NixOS 特定配置
- `darwin/home/git.nix` - macOS 特定配置

### SSH 转发

配置了 GitHub SSH 密钥转发，用于特定 IP 地址。

## 1Password 集成

- NixOS: 系统级 1Password GUI + CLI
- macOS: 通过 Homebrew 安装

## Docker 集成

- NixOS: Podman (无守护进程容器)
- macOS: Docker Desktop (Homebrew)