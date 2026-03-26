# Phase 9: 配置原生 NixOS 容器运行 vLLM，实现 GPU 直通 - Research

**Researched:** 2026-03-26
**Domain:** NixOS、vLLM、AMD ROCm、GPU 直通
**Confidence:** MEDIUM

## Summary

vLLM 是一个高性能 LLM 推理和服务引擎，支持 AMD GPU 通过 ROCm 运行。本研究探讨了在 NixOS 容器中运行 vLLM 并实现 GPU 直通的多种方案。

**关键发现：**
1. **vLLM ROCm 支持**：vLLM 0.16.0 完整支持 AMD GPU（ROCm 7.0），官方提供 ROCm Docker 镜像
2. **NixOS 容器 GPU 直通**：通过 `allowedDevices` 和 `bindMounts` 可以实现 GPU 设备和 ROCm 库的传递
3. **架构选择**：推荐使用 Podman + ROCm 容器镜像方案，比 nixos-container 更简单且与官方镜像兼容

**Primary recommendation:** 使用 Podman 运行官方 vLLM ROCm 镜像，通过设备挂载实现 GPU 直通。这是最简单且与官方支持一致的方案。

## Standard Stack

### Core
| Library/Tool | Version | Purpose | Why Standard |
|--------------|---------|---------|--------------|
| vLLM | 0.16.0 | LLM 推理引擎 | nixpkgs 官方包，支持 ROCm |
| ROCm | 7.0 | AMD GPU 计算 | 官方 vLLm ROCm 镜像使用 |
| Podman | 5.x | 容器运行时 | 项目已配置，无守护进程 |
| Python | 3.12 | 运行时环境 | vLLM 推荐版本 |

### Supporting
| Library/Tool | Version | Purpose | When to Use |
|--------------|---------|---------|-------------|
| rocmPackages | nixpkgs | ROCm 库集合 | 从源码构建时 |
| hipblas | rocmPackages | HIP BLAS 库 | GPU 线性代数运算 |
| rocblas | rocmPackages | ROCm BLAS | 底层矩阵运算 |

### Supported GPU Architectures (ROCm)
| Architecture | GPU Series | Notes |
|--------------|------------|-------|
| gfx90a | AMD Instinct MI200 | 数据中心 GPU |
| gfx942/gfx950 | AMD Instinct MI300 | 最新数据中心 GPU |
| gfx1100/gfx1101 | AMD Radeon RX 7900 | RDNA3 消费级 GPU |
| gfx1200/gfx1201 | AMD Radeon RX 9000 | RDNA4 消费级 GPU |
| gfx1150/gfx1151 | AMD Strix Point | 移动端 APU |

**重要提示：** 用户系统配置使用 `ROCR_VISIBLE_DEVICES=1` 和 `HIP_VISIBLE_DEVICES=1`，表示使用 GPU 1。需要确认该 GPU 的架构是否在支持列表中。

### Installation

**方案 A: 使用官方 ROCm Docker 镜像（推荐）**
```bash
# 拉取官方 vLLM ROCm 镜像
podman pull rocm/vllm-dev:base
# 或构建自定义镜像
podman build -f Dockerfile.rocm -t vllm-rocm .
```

**方案 B: 使用 nixpkgs vLLM 包**
```nix
# nixos/packages/default.nix
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    vllm
  ];
}
```

## Architecture Patterns

### 推荐架构：Podman + ROCm 容器

```
┌─────────────────────────────────────────────────────────┐
│                    NixOS Host                            │
│  ┌─────────────────────────────────────────────────┐    │
│  │              Podman Container                    │    │
│  │  ┌─────────────────────────────────────────┐    │    │
│  │  │           vLLM Server                    │    │    │
│  │  │    - OpenAI Compatible API (8000)        │    │    │
│  │  │    - Model Loading & Inference           │    │    │
│  │  │    - PagedAttention Memory Management    │    │    │
│  │  └─────────────────────────────────────────┘    │    │
│  │                                                  │    │
│  │  ROCm Runtime (from image)                      │    │
│  │  /dev/dri/* (GPU devices)                       │    │
│  │  /dev/kfd (AMD KFD)                             │    │
│  └─────────────────────────────────────────────────┘    │
│                                                          │
│  Host ROCm Libraries (optional, for shared use)          │
│  /opt/rocm -> bind mount (optional)                      │
└─────────────────────────────────────────────────────────┘
```

### Pattern 1: NixOS Container GPU 直通

```nix
# nixos/containers/vllm.nix
{ config, pkgs, ... }:
{
  containers.vllm = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.10.10.1";
    localAddress = "10.10.10.2";

    # GPU 设备直通
    allowedDevices = [
      { node = "/dev/dri/card0"; modifier = "rwm"; }
      { node = "/dev/dri/card1"; modifier = "rwm"; }
      { node = "/dev/dri/renderD128"; modifier = "rwm"; }
      { node = "/dev/dri/renderD129"; modifier = "rwm"; }
      { node = "/dev/kfd"; modifier = "rwm"; }
    ];

    # 挂载 ROCm 库（如果需要）
    bindMounts = {
      "/opt/rocm" = {
        hostPath = "/run/opengl-driver";  # NixOS ROCm 路径
        isReadOnly = true;
      };
    };

    # 端口转发
    forwardPorts = [{
      containerPort = 8000;
      hostPort = 8000;
      protocol = "tcp";
    }];

    config = { config, pkgs, ... }: {
      # 容器内配置
      services.vllm = {
        enable = true;
        model = "/var/lib/vllm/models";
        port = 8000;
      };
    };
  };
}
```

### Pattern 2: Podman + ROCm 镜像（推荐）

```nix
# nixos/containers/vllm.nix
{ config, pkgs, ... }:
{
  systemd.services.vllm = {
    description = "vLLM Inference Server";
    wantedBy = [ "multi-user.target" ];
    after = [ "podman.service" ];
    requires = [ "podman.service" ];

    serviceConfig = {
      Type = "simple";
      User = "root";
      ExecStart = "${pkgs.podman}/bin/podman run \
        --name vllm-server \
        --rm \
        --device /dev/kfd \
        --device /dev/dri \
        -e HSA_OVERRIDE_GFX_VERSION=10.3.0 \
        -e HIP_VISIBLE_DEVICES=1 \
        -e ROCR_VISIBLE_DEVICES=1 \
        -p 8000:8000 \
        -v /var/lib/vllm:/models \
        rocm/vllm-dev:base \
        --model /models/your-model \
        --host 0.0.0.0 \
        --port 8000";
      ExecStop = "${pkgs.podman}/bin/podman stop vllm-server";
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
```

### Pattern 3: podman-compose 编排

```yaml
# nixos/containers/vllm-compose.yml
services:
  vllm:
    image: rocm/vllm-dev:base
    container_name: vllm-server
    ports:
      - "8000:8000"
    devices:
      - /dev/kfd
      - /dev/dri
    environment:
      - HSA_OVERRIDE_GFX_VERSION=10.3.0
      - HIP_VISIBLE_DEVICES=1
      - ROCR_VISIBLE_DEVICES=1
    volumes:
      - /var/lib/vllm/models:/models:ro
      - /var/lib/vllm/cache:/root/.cache
    command: >
      --model /models/your-model
      --host 0.0.0.0
      --port 8000
      --dtype auto
      --gpu-memory-utilization 0.9
    restart: unless-stopped
```

### Anti-Patterns to Avoid

- **不要忽略 GPU 架构兼容性**：ROCm 只支持特定 GPU 架构，需要确认目标 GPU 在支持列表中
- **不要混用 CUDA 和 ROCm**：vLLM 镜像有 CUDA 和 ROCm 两个版本，不能混用
- **不要忽略 KFD 设备**：`/dev/kfd` 是 AMD GPU 核心驱动设备，必须传递到容器
- **不要忘记设置环境变量**：`HIP_VISIBLE_DEVICES` 和 `ROCR_VISIBLE_DEVICES` 必须正确设置

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| vLLM 安装 | 从源码构建 | 官方 ROCm Docker 镜像 | 依赖复杂，ROCm 配置繁琐 |
| ROCm 环境 | 手动配置所有库 | rocmPackages 或官方镜像 | 108 个包，依赖关系复杂 |
| GPU 设备映射 | 手动创建设备节点 | Podman --device | 自动处理权限和挂载 |
| OpenAI API | 自己实现 | vLLM 内置 | 生产级实现，支持流式响应 |

**Key insight:** vLLM + ROCm 的依赖链非常复杂，使用官方 Docker 镜像可以避免大量构建和配置问题。

## Common Pitfalls

### Pitfall 1: GPU 架构不支持

**What goes wrong:** vLLM 启动时报 "GFX architecture not supported"

**Why it happens:** ROCm 只支持特定的 AMD GPU 架构，消费级 GPU 可能需要设置 `HSA_OVERRIDE_GFX_VERSION`

**How to avoid:**
```bash
# 对于 RDNA2/RDNA3 消费级 GPU
export HSA_OVERRIDE_GFX_VERSION=10.3.0
# 或在 Podman 中
-e HSA_OVERRIDE_GFX_VERSION=10.3.0
```

**Warning signs:** 启动日志中出现 "hipErrorNoDevice" 或架构相关错误

### Pitfall 2: 设备权限不足

**What goes wrong:** 容器内无法访问 GPU，报 "Permission denied" 或 "Device not found"

**Why it happens:** `/dev/kfd` 和 `/dev/dri/*` 设备需要正确的权限

**How to avoid:**
```nix
# 确保用户在 render 和 video 组
users.users.zhaochanglong.extraGroups = [ "render" "video" ];
```

**Warning signs:** `rocminfo` 命令无法检测到 GPU

### Pitfall 3: 内存不足

**What goes wrong:** 模型加载时 OOM 或系统卡死

**Why it happens:** vLLM 默认使用 90% GPU 内存，需要预留系统内存

**How to avoid:**
```bash
--gpu-memory-utilization 0.8  # 降低 GPU 内存使用率
```

**Warning signs:** 模型加载进度条卡住，系统响应缓慢

### Pitfall 4: 网络访问问题

**What goes wrong:** 无法从外部访问 vLLM API

**Why it happens:** 防火墙阻止或容器网络配置错误

**How to avoid:**
```nix
networking.firewall.allowedTCPPorts = [ 8000 ];
```

**Warning signs:** curl localhost:8000 正常，但外部 IP 不通

## Code Examples

### 启动 vLLM OpenAI 兼容服务器

```bash
# 使用官方镜像启动
podman run -d \
  --name vllm-server \
  --device /dev/kfd \
  --device /dev/dri \
  -e HIP_VISIBLE_DEVICES=1 \
  -e ROCR_VISIBLE_DEVICES=1 \
  -e HSA_OVERRIDE_GFX_VERSION=10.3.0 \
  -p 8000:8000 \
  -v /var/lib/vllm/models:/models:ro \
  rocm/vllm-dev:base \
  --model /models/Qwen2.5-7B-Instruct \
  --host 0.0.0.0 \
  --port 8000 \
  --dtype auto \
  --gpu-memory-utilization 0.9
```

### OpenAI API 调用示例

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:8000/v1",
    api_key="dummy"  # vLLM 不需要真实 API key
)

response = client.chat.completions.create(
    model="Qwen2.5-7B-Instruct",
    messages=[
        {"role": "user", "content": "你好，请介绍一下自己"}
    ],
    stream=True
)

for chunk in response:
    print(chunk.choices[0].delta.content, end="")
```

### NixOS 完整配置

```nix
# nixos/containers/vllm.nix
{ config, pkgs, self, ... }:
{
  # 确保用户在必要的组
  users.users.zhaochanglong.extraGroups = [ "render" "video" ];

  # 防火墙配置
  networking.firewall.allowedTCPPorts = [ 8000 ];

  # 数据目录
  systemd.tmpfiles.rules = [
    "d /var/lib/vllm 0755 root root -"
    "d /var/lib/vllm/models 0755 root root -"
    "d /var/lib/vllm/cache 0755 root root -"
  ];

  # vLLM 服务
  systemd.services.vllm = {
    description = "vLLM Inference Server with ROCm";
    wantedBy = [ "multi-user.target" ];
    after = [ "podman.service" ];
    requires = [ "podman.service" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.podman}/bin/podman run \
        --name vllm-server \
        --rm \
        --device /dev/kfd \
        --device /dev/dri \
        -e HIP_VISIBLE_DEVICES=1 \
        -e ROCR_VISIBLE_DEVICES=1 \
        -e HSA_OVERRIDE_GFX_VERSION=10.3.0 \
        -p 8000:8000 \
        -v /var/lib/vllm/models:/models:ro \
        -v /var/lib/vllm/cache:/root/.cache \
        rocm/vllm-dev:base \
        --model /models/Qwen2.5-7B-Instruct \
        --host 0.0.0.0 \
        --port 8000 \
        --dtype auto \
        --gpu-memory-utilization 0.9";
      ExecStop = "${pkgs.podman}/bin/podman stop -t 30 vllm-server";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| CUDA-only vLLM | ROCm support | 2024 | AMD GPU 原生支持 |
| 手动 ROCm 安装 | 官方 ROCm 镜像 | 2024 | 简化部署 |
| Docker | Podman | 2025+ | 无守护进程，更安全 |

**Deprecated/outdated:**
- ROCm 5.x：已被 ROCm 7.0 取代，vLLM 0.16.0 使用 ROCm 7.0
- 手动构建 vLLM：推荐使用官方镜像

## Open Questions

1. **用户 GPU 型号确认**
   - What we know: 系统配置显示使用 GPU 1，已配置 ROCm
   - What's unclear: 具体 GPU 型号和架构
   - Recommendation: 运行 `rocminfo` 或 `lspci | grep -i vga` 确认

2. **模型存储位置**
   - What we know: 需要本地存储模型文件
   - What's unclear: 模型大小和存储空间需求
   - Recommendation: 使用 /var/lib/vllm/models 作为模型目录

3. **多 GPU 配置**
   - What we know: 系统有多个 GPU（配置中提到了 card0, card1）
   - What's unclear: 哪个 GPU 用于 vLLM
   - Recommendation: 使用 `HIP_VISIBLE_DEVICES` 指定

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | systemd service + curl |
| Config file | nixos/containers/vllm.nix |
| Quick run command | `curl -s http://localhost:8000/v1/models` |
| Full suite command | `curl -s http://localhost:8000/v1/models && curl -s -X POST http://localhost:8000/v1/chat/completions -H "Content-Type: application/json" -d '{"model": "test", "messages": [{"role": "user", "content": "hi"}]}'` |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| VLLM-01 | vLLM 服务启动 | unit | `systemctl is-active vllm` | Wave 0 |
| VLLM-02 | GPU 设备访问 | integration | `podman exec vllm-server rocminfo` | Wave 0 |
| VLLM-03 | API 端点可访问 | smoke | `curl -s http://localhost:8000/v1/models` | Wave 0 |
| VLLM-04 | 模型加载成功 | integration | `curl -s http://localhost:8000/v1/models \| jq '.data[].id'` | Wave 0 |
| VLLM-05 | 推理功能正常 | e2e | `curl -s -X POST http://localhost:8000/v1/chat/completions ...` | Wave 0 |

### Sampling Rate
- Per task commit: `systemctl is-active vllm`
- Per wave merge: `curl -s http://localhost:8000/v1/models`
- Phase gate: Full API 测试通过

### Wave 0 Gaps
- [ ] `nixos/containers/vllm.nix` - vLLM 容器配置
- [ ] `/var/lib/vllm/models` - 模型存储目录
- [ ] GPU 架构确认 - 需要用户确认 GPU 型号

## Requirements Derivation

基于研究结果，建议 Phase 9 包含以下需求：

| ID | Description | Priority |
|----|-------------|----------|
| VLLM-01 | vLLM 服务在容器内运行 | Must |
| VLLM-02 | GPU 直通配置正确（/dev/kfd, /dev/dri） | Must |
| VLLM-03 | OpenAI 兼容 API 在端口 8000 可访问 | Must |
| VLLM-04 | 模型加载和推理功能正常 | Must |
| VLLM-05 | 服务开机自启 | Should |
| VLLM-06 | 日志收集和监控 | Should |
| VLLM-07 | 模型热加载支持 | Nice |

## Sources

### Primary (HIGH confidence)
- [vLLM GitHub Repository](https://github.com/vllm-project/vllm) - 官方源码和 Dockerfile
- [vLLM ROCm Dockerfile](https://github.com/vllm-project/vllm/blob/main/docker/Dockerfile.rocm) - ROCm 构建配置
- [NixOS Container Options](https://nixos.org/manual/nixos/unstable/options) - 官方选项文档
- [nixpkgs vLLM Package](https://search.nixos.org/packages?query=vllm) - vLLM 0.16.0

### Secondary (MEDIUM confidence)
- [ROCm Documentation](https://rocm.docs.amd.com/) - AMD GPU 计算平台
- [Podman Documentation](https://podman.io/docs) - 容器运行时

### Tertiary (LOW confidence)
- WebSearch 结果 - 需要进一步验证

## Metadata

**Confidence breakdown:**
- Standard stack: MEDIUM - vLLM ROCm 支持已确认，但具体配置需要测试
- Architecture: MEDIUM - 理论方案可行，实际实现可能有坑
- Pitfalls: MEDIUM - 基于 ROCm 常见问题总结

**Research date:** 2026-03-26
**Valid until:** 2026-04-26 (ROCm/vLLM 更新较快)