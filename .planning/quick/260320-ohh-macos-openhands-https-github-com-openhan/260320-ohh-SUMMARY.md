# Quick Task 260320-ohh: 在 macOS 上面使用容器运行 OpenHands

**Status:** Complete
**Date:** 2026-03-20

---

## Summary

使用纯声明式 Nix 配置在 macOS 上运行 OpenHands AI 编程助手：

1. **Colima 容器运行时** - 通过 home-manager 模块配置
2. **OpenHands 容器** - 通过 home-manager 模块配置
3. **文档** - 完整的使用说明

---

## Files Changed

| File | Action | Description |
|------|--------|-------------|
| `shared/home/openhands.nix` | Created | OpenHands home-manager 模块 |
| `shared/home/default.nix` | Modified | 导入 openhands 模块 |
| `darwin/home/colima.nix` | Created | Colima home-manager 模块 |
| `darwin/home/zhaochanglong.nix` | Modified | 导入 colima 模块 |
| `docs/openhands-run.md` | Created | 使用文档 |

---

## Configuration

### Colima 配置

```nix
# 资源配置
memory = 8  # GB
cpu = 4     # CPUs
disk = 100  # GB
```

### OpenHands 配置

```nix
# 默认配置
image = "ghcr.io/openhands/openhands:latest"
port = 3000
llmModel = "alibaba/qwen-plus"
llmBaseurl = "https://dashscope.aliyuncs.com/compatible-mode/v1"
workspace = "~/openhands-workspace"
```

---

## Usage

### 1. 应用配置

```bash
darwin-rebuild switch --flake .#darwin
```

### 2. 设置 API Key

```bash
export LLM_API_KEY="sk-your-dashscope-api-key"
```

### 3. 启动 Colima

```bash
colima start
```

### 4. 启动 OpenHands

配置中包含 launchd agent，但需要手动启动容器：

```bash
# 方法一：使用 Docker 命令
docker run -d --rm \
  --name openhands \
  -p 3000:3000 \
  -v ~/.openhands:/.openhands \
  -v ~/openhands-workspace:/workspace \
  -e LLM_MODEL="alibaba/qwen-plus" \
  -e LLM_API_KEY="${LLM_API_KEY}" \
  -e LLM_BASE_URL="https://dashscope.aliyuncs.com/compatible-mode/v1" \
  ghcr.io/openhands/openhands:latest

# 方法二：启用 home-manager service (可选)
# 需要配置 programs.openhands.enable = true;
```

### 5. 访问 Web UI

```
http://localhost:3000
```

---

## Next Steps

1. 运行 `darwin-rebuild switch --flake .#darwin` 应用配置
2. 设置 `LLM_API_KEY` 环境变量
3. 启动 Colima: `colima start`
4. 启动 OpenHands 容器
5. 访问 http://localhost:3000

---

**Commit:** Pending
