# Phase 4: Podman 安装与初始化 - Research

**Researched:** 2026-03-20
**Domain:** Podman container runtime on macOS with Nix declarative configuration
**Confidence:** HIGH

## Summary

本阶段目标是通过 Nix 声明式配置在 macOS 上安装 Podman，初始化并启动 Podman machine，使其能够运行容器。

核心发现：
1. **安装方式**：Podman 可通过 nixpkgs 包或 Homebrew cask 安装。项目已有 Homebrew 集成（`darwin/packages/default.nix`），添加 podman cask 即可。
2. **Machine 配置**：`podman machine init` 支持 `--cpus`、`--memory`、`--disk-size` 参数。资源配置只能在 init 时设置，后续修改需删除重建或使用 `podman machine set`（Podman 5.0+）。
3. **自动启动**：macOS 无内置 Podman 服务，需通过 launchd agent 实现开机自启。
4. **网络**：macOS 默认使用 gvproxy 进行 NAT 网络，端口转发自动处理。

**Primary recommendation:** 通过 Homebrew cask 安装 Podman（复用现有配置模式），创建 launchd agent 实现 machine 自动启动，资源配置在 init 时声明为 8GB RAM + 4 CPUs。

## User Constraints (from CONTEXT.md)

### Locked Decisions
- 通过 Nix 配置声明式安装 Podman，在 darwin/packages 或 homebrew 配置中添加 podman
- 声明式固定配置：8GB RAM, 4 CPUs，配置在 Nix 表达式中定义
- 配置 launchd agent 实现自动启动，系统启动后 Podman machine 自动运行
- 使用 macOS Podman 默认 NAT + gvproxy，不配置桥接模式
- 创建验证脚本依次检查版本、machine 状态、hello-world 运行、ps 命令

### Claude's Discretion
- 验证脚本的具体实现细节
- launchd plist 文件的具体配置参数
- gvproxy 的高级配置选项（如有需要）

### Deferred Ideas (OUT OF SCOPE)
- Podman machine 资源配置的手动调整方案
- 桥接网络模式

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| podman | 5.8.1 (nixpkgs) | 容器运行时 | 开源 Docker 替代品，rootless 默认，Nix 原生支持 |
| homebrew/cask | latest | macOS 包管理 | 项目已有 Homebrew 集成，cask 安装 Podman 最简便 |
| podman-machine | bundled | VM 管理 | Podman 在 macOS 运行容器必需的轻量级虚拟机 |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| podman-compose | 1.5.0 | Docker Compose 兼容 | 需要 compose 文件管理多容器时 |
| podman-tui | 1.11.0 | 终端 UI | 需要可视化查看容器状态时 |
| qemu | (bundled) | VM 虚拟化 | Podman machine 后端，自动安装 |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Homebrew cask | nixpkgs.podman | Nix 包更声明式，但 Homebrew cask 在 darwin 中已成熟使用 |
| launchd agent | manual start | 手动启动简单但不符合声明式原则 |
| gvproxy default | bridge mode | 桥接更复杂，NAT 对单用户场景足够 |

**Installation verification:**
```bash
# Verify nixpkgs version
nix search 'github:nixos/nixpkgs/nixpkgs-unstable' '^podman$'
# Result: podman version 5.8.1

# Homebrew cask installs latest from upstream
brew info --cask podman
```

## Architecture Patterns

### Recommended Project Structure

Podman 配置将集成到现有 darwin 配置：

```
darwin/
├── default.nix          # 主配置入口（已有）
├── packages/
│   └── default.nix      # 添加 podman cask
└── home/
    └── zhaochanglong.nix # 可选：用户级配置
```

### Pattern 1: Homebrew Cask 集成

**What:** 在 `darwin/packages/default.nix` 中添加 Podman cask

**When to use:** 当项目已使用 Homebrew 管理 macOS 应用时

**Example:**
```nix
# darwin/packages/default.nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # ... existing packages
  ];

  homebrew = {
    enable = true;
    # ... existing config

    casks = [
      # ... existing casks
      "podman"  # Add this line
    ];
  };
}
```

### Pattern 2: launchd Agent 配置

**What:** 创建 launchd agent 在登录时自动启动 Podman machine

**When to use:** 需要 Podman machine 在系统启动后自动运行

**Example:**
```nix
# darwin/default.nix
{
  # ... existing config

  launchd.user.agents.podman-start = {
    command = "/usr/bin/podman machine start";
    serviceConfig = {
      KeepAlive = false;  # 只启动一次，不持续重启
      RunAtLoad = true;   # 登录时运行
      StandardOutPath = "/tmp/podman-start.log";
      StandardErrorPath = "/tmp/podman-start.err";
    };
  };
}
```

**Source:** [nix-darwin launchd 模块](https://github.com/nix-community/nix-darwin/blob/master/modules/launchd/default.nix)

### Pattern 3: Podman Machine 初始化脚本

**What:** 首次运行时自动初始化 machine（如果不存在）

**When to use:** 需要幂等配置，首次安装时自动初始化

**Example:**
```bash
#!/usr/bin/env bash
# 检查 machine 是否存在
if ! podman machine ls 2>/dev/null | grep -q "RUNNING"; then
  if ! podman machine ls 2>/dev/null | grep -q "podman"; then
    # 首次初始化，带资源配置
    podman machine init --cpus 4 --memory 8192 --disk-size 100
  fi
  podman machine start
fi
```

### Anti-Patterns to Avoid

- **不要手动运行 `podman machine init`**：应通过 Nix 配置管理，确保可重复性
- **不要在多个配置中定义 podman**：统一在 `darwin/packages/default.nix` 或 `darwin/default.nix` 中管理
- **不要忽略 machine 状态检查**：初始化前应检查是否已存在 machine

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| VM 管理 | 手动创建 qemu VM | `podman machine` | 自动处理镜像、网络、SSH 配置 |
| 端口转发 | 手动配置 NAT 规则 | gvproxy（默认） | Podman 自动管理，支持动态端口映射 |
| 开机自启 | 手动创建 plist 文件 | nix-darwin launchd 模块 | 声明式配置，Nix 管理生命周期 |
| 镜像管理 | 手动下载 tarball | `podman pull` | 支持 OCI 标准，缓存管理，层复用 |
| 容器监控 | 自写脚本轮询 | `podman ps` / `podman inspect` | 官方命令，JSON 输出，稳定 API |

**Key insight:** Podman 在 macOS 的复杂性在于 VM 管理。`podman machine` 封装了 qemu、SSH、网络配置，手动实现会遗漏 edge cases（如网络重连、资源调整）。

## Common Pitfalls

### Pitfall 1: Machine 已存在但配置不匹配

**What goes wrong:** 用户期望修改资源配置，但 `podman machine init` 在 machine 已存在时失败。

**Why it happens:** Podman 5.0 之前，`podman machine init` 不支持覆盖已有 machine。

**How to avoid:**
```bash
# 方案 1: 删除重建
podman machine stop
podman machine rm
podman machine init --cpus 4 --memory 8192

# 方案 2: 使用 podman machine set (Podman 5.0+)
podman machine set --cpus 4 --memory 8192
```

**Warning signs:** 运行 `podman machine init` 报错 "machine already exists"。

### Pitfall 2: Machine 启动失败（资源不足）

**What goes wrong:** `podman machine start` 卡住或失败。

**Why it happens:** macOS 内存不足，或 qemu 虚拟化冲突。

**How to avoid:**
- 确保至少有 16GB 物理内存（8GB 分配给 VM 后系统还需余量）
- 关闭其他占用内存的应用

**Warning signs:** `podman machine ls` 显示状态为 "Degraded" 或长时间 "Starting"。

### Pitfall 3: 端口转发不工作

**What goes wrong:** 容器端口无法通过 localhost 访问。

**Why it happens:** 容器绑定到 `127.0.0.1` 而非 `0.0.0.0`，或 gvproxy 未正确转发。

**How to avoid:**
```bash
# 明确绑定到 0.0.0.0
podman run -p 0.0.0.0:3000:3000 image
```

**Warning signs:** 容器内服务正常，但宿主机无法访问；`podman port <container>` 显示空结果。

### Pitfall 4: launchd agent 重复启动

**What goes wrong:** 每次登录都尝试启动 machine，导致错误。

**Why it happens:** launchd agent 没有检查 machine 是否已在运行。

**How to avoid:** 使用包装脚本检查状态：
```bash
#!/usr/bin/env bash
if ! podman machine ls | grep -q "RUNNING"; then
  podman machine start
fi
```

**Warning signs:** `/tmp/podman-start.err` 中出现 "machine already running" 错误。

### Pitfall 5: Nix rebuild 后 Homebrew 不同步

**What goes wrong:** `darwin-rebuild` 成功但 podman 命令找不到。

**Why it happens:** Homebrew cask 安装可能失败或路径未更新。

**How to avoid:**
```bash
# 验证安装
brew list | grep podman
which podman
podman --version
```

**Warning signs:** `podman --version` 返回 "command not found"。

## Code Examples

### 检查 Podman 安装状态
```bash
# 验证版本
podman --version
# 输出：podman version 5.8.1

# 检查 machine 状态
podman machine ls
# 输出：
# NAME         VM TYPE     CREATED        LAST STARTED    STATE
# podman-machine-default  qemu     2 weeks ago    1 hour ago    Running
```

### 初始化 Machine 带资源配置
```bash
# 首次初始化，指定资源
podman machine init --cpus 4 --memory 8192 --disk-size 100

# 查看资源配置
podman machine inspect --format '{{.VMType}} {{.CPUs}} {{.Memory}}'
```

### 启动/停止 Machine
```bash
# 启动
podman machine start

# 停止
podman machine stop

# 重启
podman machine restart
```

### 运行容器测试
```bash
# 运行 hello-world 测试
podman run --rm hello-world
# 输出：Trying to pull docker.io/library/hello-world:latest...
# Hello from Podman!

# 列出运行中容器
podman ps

# 列出所有容器（包括已停止）
podman ps -a
```

### 验证脚本模板
```bash
#!/usr/bin/env bash
set -e

echo "=== Podman Validation ==="

echo "1. Checking version..."
podman --version

echo "2. Checking machine state..."
podman machine ls
STATE=$(podman machine ls --format '{{.State}}' | head -1)
if [[ "$STATE" != "Running" ]]; then
  echo "ERROR: Machine not running (state: $STATE)"
  exit 1
fi

echo "3. Running hello-world test..."
podman run --rm hello-world

echo "4. Checking container listing..."
podman ps

echo "=== All checks passed ==="
```

### launchd Agent Plist（原始格式参考）
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>io.podman.machine-start</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/podman</string>
    <string>machine</string>
    <string>start</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <false/>
</dict>
</plist>
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Docker Desktop (付费) | Podman (免费开源) | 2024 Docker 收费政策变更 | 个人/小团队可免费使用 |
| `docker` 命令 | `podman` 命令（兼容） | 持续 | CLI 参数 95% 兼容 |
| Docker daemon | podman machine (VM) | Podman 4.0+ | macOS 必须通过 VM |
| 手动 qemu 配置 | `podman machine` 自动管理 | Podman 3.4+ | 简化 macOS 部署 |
| rootful 容器 | rootless 默认 | Podman 4.0+ | 安全性提升 |

**Deprecated/outdated:**
- **Podman 3.x:** 不支持 `podman machine set`，需删除重建修改资源
- **Docker Desktop 免费用于小公司：** 2024 年后改为收费，推荐迁移到 Podman

## Open Questions

1. **`podman machine set` 在项目 nixpkgs 版本是否可用？**
   - What we know: Podman 5.0+ 支持 `podman machine set` 修改资源
   - What's unclear: nixpkgs unstable 的 podman 5.8.1 是否完整支持
   - Recommendation: 规划阶段包含验证步骤，如不支持则采用删除重建方案

2. **launchd agent 是否需要环境变量 PATH 配置？**
   - What we know: Homebrew 安装的 podman 在 `/usr/local/bin` 或 `/opt/homebrew/bin`
   - What's unclear: launchd 环境是否包含这些路径
   - Recommendation: 使用绝对路径 `/usr/bin/podman` 或在 agent 中设置 PATH

3. **gvproxy 端口转发是否有性能开销？**
   - What we know: gvproxy 是 Podman 在 macOS 的默认网络后端
   - What's unclear: 对高吞吐场景的影响
   - Recommendation: 实现阶段基准测试，如发现问题可考虑 bridge 模式（当前 defer）

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Shell script validation (no formal test framework needed) |
| Config file | N/A |
| Quick run command | `./validate-podman.sh` (< 30 seconds) |
| Full suite command | `./validate-podman.sh` with verbose output |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| PODMAN-01 | podman 已安装 | CLI check | `podman --version` | ❌ Wave 0 |
| PODMAN-02 | machine 已初始化 | State check | `podman machine ls` | ❌ Wave 0 |
| PODMAN-03 | machine 正在运行 | State check | `podman machine ls --format '{{.State}}'` | ❌ Wave 0 |
| PODMAN-04 | 资源配置 8GB+ RAM, 4+ CPUs | Config check | `podman machine inspect` | ❌ Wave 0 |
| PODMAN-05 | 可运行容器 | Integration | `podman run --rm hello-world` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** Manual verification of individual commands
- **Per wave merge:** Run full validation script
- **Phase gate:** All 5 success criteria must pass before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `scripts/validate-podman.sh` — 覆盖所有 PODMAN-XX 要求的验证脚本
- [ ] `darwin/podman.nix` — Podman 专用配置模块（可选，推荐创建以复用 NixOS 模式）
- [ ] 验证脚本执行权限：`chmod +x scripts/validate-podman.sh`

## Sources

### Primary (HIGH confidence)
- **nixpkgs podman package** — version 5.8.1, verified via `nix search`
- **Podman official docs** — machine init/set/start commands, https://docs.podman.io/
- **nix-darwin launchd module** — user agents configuration pattern

### Secondary (MEDIUM confidence)
- **WebSearch verification** — podman machine init parameters, Homebrew cask installation
- **Project existing config** — darwin/packages/default.nix Homebrew pattern

### Tertiary (LOW confidence)
- **Community discussions** — gvproxy performance, launchd best practices (marked for validation)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — verified against nixpkgs and project config
- Architecture: HIGH — follows established nix-darwin and home-manager patterns
- Pitfalls: MEDIUM — based on WebSearch community reports, not personally verified

**Research date:** 2026-03-20
**Valid until:** ~30 days (Podman releases are stable, but machine config behavior may change in minor versions)
