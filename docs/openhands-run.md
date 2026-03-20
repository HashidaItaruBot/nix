# 在 macOS 上使用 Colima 运行 OpenHands

本文档介绍如何在 macOS 上使用 Colima 容器运行时运行 OpenHands AI 编程助手。

## 前置条件

### 1. 安装 Colima

使用 Nix 安装：

```bash
# 通过 darwin-rebuild 应用配置
darwin-rebuild switch --flake .#darwin
```

或者手动安装：

```bash
# Homebrew
brew install colima

# Nix
nix profile install nixpkgs#colima
```

### 2. 初始化 Colima

运行初始化脚本：

```bash
./scripts/colima-init.sh
```

或者手动执行：

```bash
# 启动 Colima (8GB RAM, 4 CPUs)
colima start --memory 8 --cpu 4 --disk 100
```

### 3. 配置 LLM API Key

OpenHands 需要配置 LLM 后端。使用阿里百炼 DashScope：

```bash
# 导出 API Key
export LLM_API_KEY="sk-your-dashscope-api-key"

# 可选：自定义模型
export LLM_MODEL="alibaba/qwen-plus"

# 可选：自定义 Base URL
export LLM_BASE_URL="https://dashscope.aliyuncs.com/compatible-mode/v1"
```

## 快速启动

### 运行 OpenHands

```bash
./scripts/run-openhands.sh
```

脚本会自动：
1. 检查 Colima 运行状态
2. 验证 API Key 配置
3. 创建工作目录
4. 启动 OpenHands 容器

### 访问 Web UI

容器启动后，在浏览器访问：

```
http://localhost:3000
```

## 手动运行

### 启动容器

```bash
docker run -d --rm \
    --name openhands \
    -p 3000:3000 \
    -v ~/.openhands:/.openhands \
    -v ~/openhands-workspace:/workspace \
    -e LLM_MODEL="alibaba/qwen-plus" \
    -e LLM_API_KEY="${LLM_API_KEY}" \
    -e LLM_BASE_URL="https://dashscope.aliyuncs.com/compatible-mode/v1" \
    ghcr.io/openhands/openhands:latest
```

### 查看日志

```bash
docker logs -f openhands
```

### 停止容器

```bash
docker stop openhands
```

## 配置选项

### 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `LLM_MODEL` | `alibaba/qwen-plus` | LLM 模型标识 |
| `LLM_API_KEY` | (必需) | DashScope API Key |
| `LLM_BASE_URL` | `https://dashscope.aliyuncs.com/compatible-mode/v1` | API 端点 |
| `HOST_PORT` | `3000` | Web UI 端口 |

### 支持的模型

```bash
# Qwen 系列
export LLM_MODEL="alibaba/qwen-plus"
export LLM_MODEL="alibaba/qwen-turbo"
export LLM_MODEL="alibaba/qwen-max"

# Kimi 系列
export LLM_MODEL="alibaba/kimi-k2"
```

### 持久化配置

OpenHands 配置文件存储在 `~/.openhands`，可以编辑：

```toml
# ~/.openhands/config.toml
[core]
llm_model = "alibaba/qwen-plus"
llm_api_key = "sk-xxxxx"
llm_base_url = "https://dashscope.aliyuncs.com/compatible-mode/v1"

[sandbox]
workspace_base = "/workspace"
```

## 工作区使用

### 创建项目

```bash
# 创建工作目录
mkdir -p ~/openhands-workspace/my-project

# 在 Web UI 中，OpenHands 可以访问 /workspace 下的所有文件
```

### 文件挂载说明

- `~/.openhands` → 容器内 `/.openhands` (配置文件持久化)
- `~/openhands-workspace` → 容器内 `/workspace` (工作区文件)

## 常见问题

### Colima 无法启动

```bash
# 重置 Colima
colima stop
colima delete
colima start --memory 8 --cpu 4 --disk 100
```

### 容器无法访问网络

```bash
# 检查 Colima 状态
colima status

# 重启 Colima
colima restart
```

### API Key 验证失败

1. 确认 API Key 格式正确（以 `sk-` 开头）
2. 确认 API Key 有足够额度
3. 测试 API 连接：

```bash
curl -X POST "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions" \
  -H "Authorization: Bearer ${LLM_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"model":"qwen-plus","messages":[{"role":"user","content":"hello"}]}'
```

### 容器启动后立即退出

```bash
# 查看日志
docker logs openhands

# 检查资源是否足够
colima ssh
top
```

### 卷挂载权限问题

确保目录存在且有正确权限：

```bash
mkdir -p ~/.openhands ~/openhands-workspace
chmod 755 ~/.openhands ~/openhands-workspace
```

## 资源清理

### 停止并清理容器

```bash
docker stop openhands
```

### 删除 Colima

```bash
colima stop
colima delete
```

## 相关链接

- [OpenHands GitHub](https://github.com/OpenHands/OpenHands)
- [Colima GitHub](https://github.com/abiosoft/colima)
- [阿里百炼 DashScope 文档](https://help.aliyun.com/zh/dashscope/)
