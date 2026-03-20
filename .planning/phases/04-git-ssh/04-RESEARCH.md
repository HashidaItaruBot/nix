# Phase 4: Colima 安装与初始化 - Research

**Researched:** 2026-03-20
**Domain:** Colima container runtime on macOS with Nix declarative configuration
**Confidence:** HIGH

## Summary

本阶段目标是通过 Nix 声明式配置在 macOS 上安装 Colima，初始化并启动 Colima VM，使其能够运行 Docker 容器。这是 v1.3 的第一个 phase。

核心发现：
1. **安装方式**：Colima 可通过 Homebrew cask、Nix、MacPorts 安装。项目已有 Homebrew 集成（`darwin/packages/default.nix`），添加 colima cask 最简便。
2. **VM 配置**：`colima start --memory 8 --cpu 4 --disk 100` 支持资源配置。Colima 0.6+ 支持启动时指定资源，无需单独 init 步骤。
3. **Docker 兼容性**：Colima 自动创建 `/var/run/docker.sock`  symlink，`docker` 命令无缝工作。
4. **自动启动**：macOS 无内置 Colima 服务，需通过 home-manager 模块或 launchd agent 实现开机自启。

**Primary recommendation:** 通过 Homebrew cask 安装 Colima（复用现有配置模式），创建 home-manager 模块管理 Colima 配置和自动启动，资源配置为 8GB RAM + 4 CPUs + 100GB disk（OpenHands 推荐配置）。

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- 通过 Homebrew cask 在 darwin/packages/default.nix 中添加 Colima
- 系统级安装，符合项目现有的 Homebrew 模式
- 不单独创建 colima.nix 模块，直接在 packages 中配置
- 通过 home-manager 模块管理 Colima 配置
- 创建 darwin/home/colima.nix 模块
- 在 zhaochanglong.nix 中导入 colima 模块
- 配置自动处理 VM 初始化和启动
- 8GB RAM, 4 CPUs, 100GB disk（OpenHands 推荐最低配置）
- 配置在 home-manager 模块中声明式定义
- 使用 home-manager 的 autoStart 选项（如有）
- 或配置 launchd agent 作为备选方案
- 用户登录时自动启动 Colima machine
- 手动执行验证命令
- 不创建专门的验证脚本
- 用户按 checklist 逐项验证

### Claude's Discretion
- home-manager colima 模块的具体实现细节
- 配置参数的具体命名和结构
- 错误处理和日志配置

### Deferred Ideas (OUT OF SCOPE)
- 手动初始化脚本方案 — 当前选择 home-manager 模块，defer 脚本方案
- 高配 VM 资源（16GB/8CPU）— 当前选择默认配置，可后续调整
- Colima 高级配置（网络、镜像存储位置）— 当前选择默认值
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| COLIMA-01 | 通过 Homebrew 安装 Colima | Homebrew cask 配置模式已在 darwin/packages/default.nix 中建立 |
| COLIMA-02 | 初始化 Colima VM (`colima start`) | colima start 命令支持 --memory, --cpu, --disk 参数 |
| COLIMA-03 | 配置 Colima VM 资源（8GB+ RAM, 4+ CPUs） | 资源配置通过 colima start --memory 8 --cpu 4 --disk 100 |
| COLIMA-04 | 配置 launchd 自动启动 | home-manager launchd.user.agents 模式可用于自动启动 |
| COLIMA-05 | 验证 Colima 容器运行能力 | docker run --rm hello-world 测试验证 |
</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| colima | 0.10.1 (latest) | 容器运行时 VM | 开源 Docker Desktop 替代品，macOS 原生支持，Docker API 兼容 |
| homebrew/cask | latest | macOS 包管理 | 项目已有 Homebrew 集成，cask 安装 Colima 最简便 |
| docker CLI | 27.x+ | Docker 客户端 | Colima 提供 Docker 兼容 socket，使用标准 docker 命令 |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| lima | bundled | VM 虚拟化 | Colima 底层依赖，自动安装 |
| qemu | bundled | 虚拟化后端 | Intel Mac 需要，Apple Silicon 使用 vz 框架 |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Homebrew cask | nixpkgs.colima | Nix 包更声明式，但 Homebrew cask 在 darwin 中已成熟使用 |
| colima start CLI | config.yaml 文件 | CLI 更直接，config.yaml 适合复杂配置 |
| launchd agent | manual start | 手动启动简单但不符合声明式原则 |

**Installation verification:**
```bash
# Verify Homebrew cask
brew info --cask colima
# Latest: 0.10.1 (released 2026-02-22)

# Verify nixpkgs version
nix search nixpkgs#colima
```

## Architecture Patterns

### Recommended Project Structure

Colima 配置将集成到现有 darwin 配置：

```
darwin/
├── packages/
│   └── default.nix      # 添加 colima cask
└── home/
    ├── colima.nix       # Colima home-manager 模块 (新建)
    └── zhaochanglong.nix # 导入 colima 模块
```

### Pattern 1: Homebrew Cask 集成

**What:** 在 `darwin/packages/default.nix` 中添加 Colima cask

**When to use:** 当项目已使用 Homebrew 管理 macOS 应用时

**Example:**
```nix
# darwin/packages/default.nix
{ pkgs, ... }:
{
  homebrew = {
    enable = true;
    casks = [
      # ... existing casks
      "colima"  # Add this line
    ];
  };
}
```

**Source:** [Colima Official Installation](https://github.com/abiosoft/colima#installation)

### Pattern 2: Colima home-manager 模块

**What:** 创建 `darwin/home/colima.nix` 模块管理 Colima 配置和自动启动

**When to use:** 需要声明式管理 Colima VM 配置和开机自启

**Example:**
```nix
# darwin/home/colima.nix
{ pkgs, lib, config, ... }:
{
  # 安装 colima 和 docker 客户端
  home.packages = with pkgs; [
    colima
    docker
  ];

  # 配置自动启动
  launchd.user.agents.colima = {
    command = "${pkgs.colima}/bin/colima start --memory 8 --cpu 4 --disk 100";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = false;  # 只启动一次，不持续重启
      StandardOutPath = "/tmp/colima-start.log";
      StandardErrorPath = "/tmp/colima-start.err";
    };
  };
}
```

### Pattern 3: Colima 初始化脚本（备选）

**What:** 首次运行时幂等初始化 Colima VM

**When to use:** 需要确保 VM 已初始化并启动

**Example:**
```bash
#!/usr/bin/env bash
# 检查 VM 是否运行
if ! colima list 2>/dev/null | grep -q "Running"; then
  # 启动 VM（带资源配置）
  colima start --memory 8 --cpu 4 --disk 100
fi
```

### Anti-Patterns to Avoid

- **不要手动运行 `colima start` 不带参数**：应固定资源配置确保一致性
- **不要在多个配置中定义 colima**：统一在 `darwin/packages/default.nix` 和 `darwin/home/colima.nix` 中管理
- **不要忽略 VM 状态检查**：启动前应检查是否已在运行
- **不要忘记安装 docker 客户端**：Colima 只提供 VM，需要单独安装 docker 命令

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| VM 管理 | 手动创建 qemu VM | `colima start` | 自动处理镜像、网络、SSH 配置、端口转发 |
| Docker socket 配置 | 手动创建 symlink | Colima 自动处理 | Colima 自动创建 `/var/run/docker.sock` |
| 端口转发 | 手动配置 NAT 规则 | Colima 默认 | 自动端口映射，支持动态端口 |
| 开机自启 | 手动创建 plist 文件 | nix-darwin launchd 模块 | 声明式配置，Nix 管理生命周期 |
| 镜像管理 | 手动下载 tarball | `docker pull` | 支持 OCI 标准，缓存管理，层复用 |

**Key insight:** Colima 在 macOS 的复杂性在于 VM 和 Docker socket 管理。`colima start` 封装了 lima、qemu/vz、网络配置、Docker 兼容层，手动实现会遗漏 edge cases。

## Common Pitfalls

### Pitfall 1: VM 资源配置在已存在 VM 上不生效

**What goes wrong:** 用户修改 `colima start` 参数但资源配置不更新。

**Why it happens:** Colima VM 创建后，资源配置（CPU、内存、磁盘）只能在创建时设置。修改需要删除重建或使用 `colima start --edit`。

**How to avoid:**
```bash
# 方案 1: 删除重建
colima stop
colima delete
colima start --memory 8 --cpu 4 --disk 100

# 方案 2: 编辑配置启动
colima start --edit
# 在编辑器中修改 memory, cpu, disk
```

**Warning signs:** 运行 `colima start --memory 8` 但 `colima list` 显示旧配置。

### Pitfall 2: Docker 客户端未安装

**What goes wrong:** Colima VM 运行但 `docker` 命令找不到。

**Why it happens:** Colima 只提供容器运行时 VM，Docker CLI 需要单独安装。

**How to avoid:**
```bash
# Homebrew 安装 docker CLI
brew install docker

# 或在 Nix 中添加
nix-env -iA nixpkgs.docker
```

**Warning signs:** `colima status` 显示 Running，但 `docker --version` 返回 "command not found"。

### Pitfall 3: launchd agent 重复启动

**What goes wrong:** 每次登录都尝试启动 Colima，导致错误。

**Why it happens:** launchd agent 没有检查 Colima 是否已在运行。

**How to avoid:** 使用包装脚本检查状态：
```bash
#!/usr/bin/env bash
if ! colima list 2>/dev/null | grep -q "Running"; then
  colima start --memory 8 --cpu 4 --disk 100
fi
```

**Warning signs:** `/tmp/colima-start.err` 中出现 "instance already running" 错误。

### Pitfall 4: Apple Silicon vs Intel 架构差异

**What goes wrong:** Colima 在 Apple Silicon 和 Intel Mac 上行为不同。

**Why it happens:** Apple Silicon 使用 `vz` 虚拟化框架，Intel 使用 qemu。

**How to avoid:**
- 默认配置自动选择合适后端
- 如需强制指定：`colima start --vm-type vz` (Apple Silicon) 或 `--vm-type qemu` (Intel)

**Warning signs:** 启动缓慢或虚拟化错误。

### Pitfall 5: Nix rebuild 后 Homebrew 不同步

**What goes wrong:** `darwin-rebuild` 成功但 colima 命令找不到。

**Why it happens:** Homebrew cask 安装可能失败或路径未更新。

**How to avoid:**
```bash
# 验证安装
brew list | grep colima
which colima
colima --version
```

**Warning signs:** `colima --version` 返回 "command not found"。

## Code Examples

### 检查 Colima 安装状态
```bash
# 验证版本
colima --version
# 输出：colima version 0.10.1

# 检查 VM 状态
colima list
# 输出：
# COLIMA    VERSION     STATUS      ARCH        CPUS    MEMORY    DISK
# default   0.10.1      Running     aarch64     4       8GiB      100GiB
```

### 启动 VM 带资源配置
```bash
# 首次启动，指定资源
colima start --memory 8 --cpu 4 --disk 100

# 查看配置
colima list --json
```

### 启动/停止 VM
```bash
# 启动
colima start

# 停止
colima stop

# 重启
colima restart

# 删除
colima delete
```

### 运行容器测试
```bash
# 运行 hello-world 测试
docker run --rm hello-world
# 输出：Hello from Docker!

# 列出运行中容器
docker ps

# 列出所有容器（包括已停止）
docker ps -a
```

### 验证 Checklist（手动）
```bash
# 1. 检查版本
colima --version

# 2. 检查 VM 状态
colima status
# 或
colima list

# 3. 检查资源配置
colima list | grep -E "CPUS.*MEMORY.*DISK"

# 4. 运行 hello-world
docker run --rm hello-world

# 5. 检查 docker ps
docker ps
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Docker Desktop (个人免费) | Colima (完全开源免费) | 2024 Docker 收费政策变更 | 个人/小团队可免费使用 |
| `docker` 命令 + Docker Desktop | `docker` 命令 + Colima | 持续 | CLI 100% 兼容 |
| Docker daemon | Colima VM (lima + qemu/vz) | Colima 0.3+ | macOS 必须通过 VM |
| 手动虚拟机配置 | `colima start` 自动管理 | Colima 0.2+ | 简化 macOS 部署 |
| rootful 容器 | rootless 默认 | Colima 0.4+ | 安全性提升 |

**Deprecated/outdated:**
- **Docker Desktop 免费用于小公司：** 2024 年后改为收费，推荐迁移到 Colima
- **手动 lima 配置:** Colima 0.2+ 封装了 lima 配置，直接使用 `colima start`

## Open Questions

1. **home-manager 是否有 services.colima 模块？**
   - What we know: nix-darwin 和 home-manager 社区可能有 Colima 模块
   - What's unclear: 模块是否存在及具体配置选项
   - Recommendation: 如不存在，使用 launchd.user.agents 备选方案

2. **Colima VM 资源配置精确语法？**
   - What we know: `colima start --memory 8 --cpu 4 --disk 100` 是标准语法
   - What's unclear: home-manager 模块中是否支持直接配置
   - Recommendation: 规划阶段验证 launchd 方案

3. **Docker socket 权限是否需要额外配置？**
   - What we know: Colima 自动创建 `/var/run/docker.sock` symlink
   - What's unclear: macOS 权限是否需 sudo
   - Recommendation: 实现阶段验证 `docker run hello-world`

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Manual verification checklist (no formal test framework needed) |
| Config file | N/A |
| Quick run command | Manual commands (< 30 seconds each) |
| Full suite command | Full checklist from CONTEXT.md success criteria |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| COLIMA-01 | colima 已安装 | CLI check | `colima --version` | ❌ Wave 0 |
| COLIMA-02 | VM 已初始化 | State check | `colima list` | ❌ Wave 0 |
| COLIMA-03 | VM 正在运行，8GB+ RAM, 4+ CPUs | State check | `colima list` 输出检查 | ❌ Wave 0 |
| COLIMA-04 | launchd 自动启动配置 | Config check | `launchctl list | grep colima` | ❌ Wave 0 |
| COLIMA-05 | 可运行容器 | Integration | `docker run --rm hello-world` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** Manual verification of individual commands
- **Per wave merge:** Run full validation checklist
- **Phase gate:** All 5 success criteria must pass before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] Manual verification checklist — 覆盖所有 COLIMA-XX 要求的验证步骤
- [ ] `darwin/home/colima.nix` — Colima home-manager 模块（新建）
- [ ] `darwin/packages/default.nix` — 添加 colima cask

## Sources

### Primary (HIGH confidence)
- **Colima GitHub Repository** — version 0.10.1, https://github.com/abiosoft/colima
- **Colima Installation Docs** — Homebrew, Nix, MacPorts options, https://colima.run/docs/install/
- **Colima Usage Docs** — start command options, https://colima.run/docs/usage/
- **Project existing config** — darwin/packages/default.nix Homebrew pattern

### Secondary (MEDIUM confidence)
- **WebSearch verification** — colima start parameters, Docker socket setup
- **Project docs** — docs/openhands-run.md Colima installation notes

### Tertiary (LOW confidence)
- **Community discussions** — home-manager colima module existence, launchd best practices (marked for validation)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — verified against GitHub releases and Homebrew
- Architecture: HIGH — follows established nix-darwin and home-manager patterns
- Pitfalls: MEDIUM — based on community reports and Colima documentation

**Research date:** 2026-03-20
**Valid until:** ~30 days (Colima releases are stable, but VM config behavior may change in minor versions)
