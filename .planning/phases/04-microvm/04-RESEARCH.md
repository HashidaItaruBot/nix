# Phase 4: MicroVM 基础设施 - Research

**Researched:** 2026-03-20
**Domain:** microvm.nix, cloud-hypervisor, NixOS virtualization
**Confidence:** HIGH

## Summary

Phase 4 的目标是在 NixOS 宿主机上配置 MicroVM 基础设施，使用 cloud-hypervisor 运行 OpenClaw NixOS guest。microvm.nix 项目提供了完整的 NixOS 模块，支持多种 hypervisor（包括 cloud-hypervisor），并通过声明式配置管理 MicroVM 的生命周期。

**Primary recommendation:** 使用 microvm.nix 的 host 模块在宿主机创建 systemd 服务和管理 TAP 接口，guest 配置使用 cloud-hypervisor 作为 hypervisor，通过 virtiofs 只读共享 `/nix/store`，使用 writable overlay 支持运行时写入。

## User Constraints (from CONTEXT.md)

### Locked Decisions

| 决策 | 配置 |
|------|------|
| A1 | 创建独立的 `nixos/microvm.nix` 文件（宿主机导入） |
| A2 | 创建 `nixos/microvm/` 目录，`default.nix` 为 host 配置，`openclaw.nix` 为 guest 配置 |
| A3 | OpenClaw 通过 nix-openclaw home-manager 模块在 guest 内部部署 |
| A4 | 多文件结构，每个 MicroVM 独立子目录 |
| Hypervisor | cloud-hypervisor |
| 内存 | 2GB |
| CPU | 2 vCPU |
| 控制 socket | 默认配置（优雅关闭） |
| 网络模式 | **NAT 模式**（仅 host 访问） |
| Guest IP | DHCP（内部网 10.0.2.x） |
| imageType | tiny（最小化镜像） |
| writable overlay | true（支持 Playwright 浏览器下载） |
| Xvfb | 无头图形环境（用于 Playwright headed 模式） |

### Claude's Discretion

- 具体 Nix 配置语法和模块结构
- virtiofs 只读共享的详细配置
- Xvfb 在 guest 中的配置方式

### Deferred Ideas (OUT OF SCOPE)

- 未来扩展：添加第二个 MicroVM 时的子目录结构
- 未来扩展：LAN 访问的桥接模式
- 未来扩展：完整图形界面的 virtio-gpu + VNC

## Standard Stack

### Core

| Library/Module | Version | Purpose | Why Standard |
|----------------|---------|---------|--------------|
| microvm.nix | v1.0+ (flake) | NixOS MicroVM 框架 | 官方推荐，支持 cloud-hypervisor，systemd 集成 |
| cloud-hypervisor | ~42.0 (via nixpkgs) | Hypervisor | Rust 编写，内存安全，启动快，microvm.nix 原生支持 |
| virtiofsd | 1.0+ | virtio-fs 服务 | cloud-hypervisor virtiofs 共享必需 |

### Supporting

| Library/Module | Version | Purpose | When to Use |
|----------------|---------|---------|-------------|
| systemd-networkd | 250+ | 网络管理 | microvm.nix optimize.enable 默认启用 |
| TAP 接口 | kernel | 虚拟网络接口 | 所有 MicroVM 网络配置必需 |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| cloud-hypervisor | qemu | qemu 支持更广泛但更重；cloud-hypervisor 更轻量但不支持 9p |
| virtiofs | 9p | virtiofs 性能更好但需要 virtiofsd 服务；9p 内置但慢 |
| TAP 网络 | user 网络 | cloud-hypervisor 不支持 user 网络，必须用 TAP |

**Installation:**

microvm.nix 已作为 flake input 引入：
```nix
# flake.nix
inputs.microvm.url = "github:microvm-nix/microvm.nix";
```

宿主机导入 host 模块：
```nix
# nixos/default.nix 或 nixos/microvm/default.nix
imports = [
  inputs.microvm.nixosModules.host
];
```

**Version verification:**
```bash
# 验证 microvm.nix 版本
nix flake metadata github:microvm-nix/microvm.nix
# 验证 cloud-hypervisor 版本
nix eval 'nixpkgs#cloud-hypervisor.version'
```

## Architecture Patterns

### Recommended Project Structure

```
nixos/microvm/
├── default.nix         # Host 配置：导入 microvm.nixosModules.host
└── openclaw.nix        # Guest 配置：定义 openclaw VM 配置
```

### Host Module Pattern

**What:** 在宿主机导入 `microvm.nixosModules.host` 模块，创建 systemd 服务、TAP 接口和 virtiofsd 服务

**When to use:** 所有需要 declarative 运行 MicroVM 的场景

**Example:**
```nix
# nixos/microvm/default.nix
{ config, lib, pkgs, inputs, ... }: {
  imports = [
    inputs.microvm.nixosModules.host
  ];

  # 可选：配置 autostart 的 MicroVM 列表
  microvm.autostart = [ "openclaw" ];

  # 配置 MicroVM 状态目录
  microvm.stateDir = "/var/lib/microvms";
}
```

**Source:** [microvm.nix host documentation](https://github.com/microvm-nix/microvm.nix/blob/main/doc/src/host.md)

### Guest Configuration Pattern (cloud-hypervisor)

**What:** 使用 `microvm.nixosModules.microvm` 模块定义 MicroVM 配置

**When to use:** 定义每个 MicroVM guest

**Example:**
```nix
# nixos/microvm/openclaw.nix
{ config, lib, pkgs, inputs, ... }: {
  imports = [
    inputs.microvm.nixosModules.microvm
  ];

  networking.hostName = "openclaw";

  microvm = {
    hypervisor = "cloud-hypervisor";
    vcpu = 2;
    mem = 2048;
    socket = "/var/lib/microvms/openclaw/control.sock";

    # virtiofs 只读共享 /nix/store
    shares = [ {
      proto = "virtiofs";
      tag = "ro-store";
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
    } ];

    # writable overlay 支持运行时写入
    writableStoreOverlay = "/nix/.rw-store";
    volumes = [ {
      image = "rw-store.img";
      mountPoint = config.microvm.writableStoreOverlay;
      size = 2048;  # 2GB
    } ];
  };

  # 安装必要的工具
  environment.systemPackages = with pkgs; [
    git curl wget vim nodejs_22 python3 gcc make jq htop
  ];
}
```

**Source:** [microvm.nix declaring documentation](https://github.com/microvm-nix/microvm.nix/blob/main/doc/src/declaring.md)

### cloud-hypervisor Configuration

**What:** cloud-hypervisor 的具体配置参数

| Option | Example | Description |
|--------|---------|-------------|
| `microvm.vcpu` | 2 | vCPU 数量 |
| `microvm.mem` | 2048 | 内存 (MB) |
| `microvm.socket` | "control.sock" | 控制 socket（用于优雅关闭） |
| `microvm.hypervisor` | "cloud-hypervisor" | 指定 hypervisor |

**cloud-hypervisor 命令行参数生成：**
```
--cpus boot=2
--mem size=2048M,mergeable=on,shared=on
--api-socket /path/to/control.sock
--vsock cid=3,socket=notify.vsock  # systemd-notify 支持
```

**Source:** [cloud-hypervisor.nix runner](https://github.com/microvm-nix/microvm.nix/blob/main/lib/runners/cloud-hypervisor.nix)

### virtiofs Share Configuration

**What:** 使用 virtiofs 共享宿主机目录到 guest

**Important:** cloud-hypervisor **仅支持** virtiofs，不支持 9p

```nix
microvm.shares = [ {
  proto = "virtiofs";  # cloud-hypervisor 必需
  tag = "ro-store";    # 在 guest 中识别的标签
  source = "/nix/store";  # 宿主机路径
  mountPoint = "/nix/.ro-store";  # guest 挂载点
} ];
```

**只读保证：** 不在 `shares` 中设置 `readonly = false`，默认就是只读。guest 无法通过 virtiofs 写入宿主机。

**Source:** [microvm.nix shares documentation](https://github.com/microvm-nix/microvm.nix/blob/main/doc/src/shares.md)

### writable Store Overlay

**What:** 使用 overlay 文件系统提供可写的 `/nix/store`

**When to use:** 需要在 guest 中动态安装 Nix 包（如 Playwright 浏览器）

```nix
{ config, ... }:
{
  microvm.writableStoreOverlay = "/nix/.rw-store";

  microvm.volumes = [ {
    image = "rw-store.img";
    mountPoint = config.microvm.writableStoreOverlay;
    size = 2048;  # MB
  } ];

  # Nix 配置使用 overlay
  nix.settings.store = {
    "overlay:" = config.microvm.writableStoreOverlay;
  };
}
```

**Caveat:** Nix database 在重启后会忘记构建的包，建议重建 overlay 或删除后重新创建。

**Source:** [microvm.nix shares - writable overlay](https://github.com/microvm-nix/microvm.nix/blob/main/doc/src/shares.md#writable-nixstore-overlay)

### 网络配置 (NAT 模式)

**关键发现:** cloud-hypervisor **不支持** QEMU 的 user 网络（slirp/NAT）。microvm.nix 中 cloud-hypervisor 仅支持 `tap` 和 `macvtap` 接口类型。

**CONTEXT.md 决定的是 "NAT 模式"**——这指的是通过 TAP 接口和宿主机网桥实现的隔离网络，guest 获得内部 IP（如 10.0.2.x），外部无法直接访问。

```nix
microvm.interfaces = [ {
  type = "tap";
  id = "microvm-openclaw";  # TAP 接口名称
  mac = "02:00:00:00:00:01";  # 本地管理的 MAC 地址
} ];
```

**宿主机网络隔离：** 通过不将 TAP 接口桥接到物理网络，guest 仅能通过宿主机访问外部网络。

**Source:** [microvm.nix interfaces documentation](https://github.com/microvm-nix/microvm.nix/blob/main/doc/src/interfaces.md)

### Xvfb 无头图形配置

**What:** 在 guest 中配置 Xvfb 提供虚拟显示环境

**When to use:** Playwright headed 模式测试，无实际显示输出

```nix
# nixos/microvm/openclaw.nix
{ pkgs, ... }: {
  # 安装 Xvfb
  environment.systemPackages = with pkgs; [ xorg.xvfb ];

  # 配置 Xvfb systemd 服务
  systemd.services.xvfb = {
    description = "Xvfb Virtual Display";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.xorg.xvfb}/bin/Xvfb :0 -screen 0 1280x1024x24";
      Restart = "on-failure";
    };
    environment = {
      DISPLAY = ":0";
    };
  };

  # 设置环境变量
  environment.variables = {
    DISPLAY = ":0";
  };
}
```

**Source:** NixOS X server 模块和 Xvfb 标准配置

## Anti-Patterns to Avoid

- **使用 9p 与 cloud-hypervisor：** cloud-hypervisor 不支持 9p，必须用 virtiofs
- **忘记配置控制 socket：** 没有 socket 就无法优雅关闭 MicroVM
- **在 guest 中安装太多包：** 使用 writable overlay 时，重启后 Nix DB 会忘记包
- **多队列 TAP 接口：** vCPU > 1 时需要 `multi_queue` TAP 接口

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Hypervisor 管理 | 自己写 systemd 服务 | microvm.nix host 模块 | 自动创建 TAP、virtiofsd、VM 服务，依赖正确 |
| virtiofs 服务 | 手动运行 virtiofsd | microvm.nixosModules.host 的 virtiofsd@ 服务 | 自动管理 socket、权限、生命周期 |
| 网络接口 | 手动创建 TAP | microvm-tap-interfaces@ 服务 | 系统启动时自动创建 |
| 虚拟机镜像 | 手动创建 qcow2 | microvm 自动构建的 erofs/squashfs | 自动包含需要的 Nix store 子集 |

**Key insight:** microvm.nix 的核心价值是将整个 MicroVM 生命周期（构建、启动、网络、存储）统一为声明式 Nix 配置。

## Common Pitfalls

### Pitfall 1: cloud-hypervisor 不支持 9p
**What goes wrong:** 配置 `proto = "9p"` 与 cloud-hypervisor 一起使用会失败
**Why it happens:** cloud-hypervisor 仅实现 virtio-fs，未实现 9p
**How to avoid:** 始终使用 `proto = "virtiofs"` 与 cloud-hypervisor
**Warning signs:** 启动时报 "unsupported share protocol" 错误

### Pitfall 2: TAP 接口权限问题
**What goes wrong:** MicroVM 启动失败，报 TAP 接口权限错误
**Why it happens:** TAP 接口属于 root，用户无法访问
**How to avoid:** 使用 microvm.nix host 模块的 systemd 服务，自动处理权限
**Warning signs:** "Permission denied" on `/dev/net/tun`

### Pitfall 3: writable overlay 数据丢失
**What goes wrong:** 重启后 guest 中安装的包消失
**Why it happens:** overlay 文件系统不与 Nix DB 同步
**How to avoid:** 接受此行为，需要持久化时使用 volumes 挂载数据目录
**Warning signs:** 重启后 `/nix/store` 中的新包无法访问

### Pitfall 4: vCPU > 1 但 TAP 接口无 multi_queue
**What goes wrong:** 网络性能低下，丢包严重
**Why it happens:** 单队列 TAP 无法并行处理多 vCPU 的网络请求
**How to avoid:** 创建 TAP 接口时添加 `multi_queue` 参数
**Warning signs:** `ethtop -S tap0` 显示队列丢弃

### Pitfall 5: virtiofs ZFS 兼容性问题
**What goes wrong:** virtiofs 在 ZFS 数据集上挂载失败
**Why it happens:** ZFS 默认不支持 xattr 和 ACL
**How to avoid:** ZFS 数据集设置 `-o xattr=sa -o acltype=posixacl`
**Warning signs:** "Operation not supported" 挂载错误

## Code Examples

### Host Module Setup (nixos/microvm/default.nix)

```nix
# nixos/microvm/default.nix
{ config, lib, pkgs, inputs, ... }: {
  imports = [
    inputs.microvm.nixosModules.host
  ];

  # 配置 autostart 的 MicroVM
  microvm.autostart = [ "openclaw" ];

  # 状态目录
  microvm.stateDir = "/var/lib/microvms";
}
```

### Guest Configuration (nixos/microvm/openclaw.nix)

```nix
# nixos/microvm/openclaw.nix
{ config, lib, pkgs, inputs, ... }: {
  imports = [
    inputs.microvm.nixosModules.microvm
    # 稍后在 Phase 7 添加
    # inputs.nix-openclaw.nixosModules.nix-openclaw
  ];

  networking.hostName = "openclaw";

  # microvm 核心配置
  microvm = {
    hypervisor = "cloud-hypervisor";
    vcpu = 2;
    mem = 2048;
    socket = "/var/lib/microvms/openclaw/control.sock";

    # virtiofs 只读共享
    shares = [ {
      proto = "virtiofs";
      tag = "ro-store";
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
    } ];

    # writable overlay for Playwright
    writableStoreOverlay = "/nix/.rw-store";
    volumes = [ {
      image = "rw-store.img";
      mountPoint = config.microvm.writableStoreOverlay;
      size = 2048;
    } ];

    # TAP 网络接口
    interfaces = [ {
      type = "tap";
      id = "microvm-openclaw";
      mac = "02:00:00:00:00:01";
    } ];
  };

  # 安装工具
  environment.systemPackages = with pkgs; [
    git curl wget vim nodejs_22 python3 gcc make jq htop
    xorg.xvfb  # Xvfb
  ];

  # Xvfb 服务
  systemd.services.xvfb = {
    description = "Xvfb Virtual Display";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.xorg.xvfb}/bin/Xvfb :0 -screen 0 1280x1024x24";
      Restart = "on-failure";
    };
    environment.DISPLAY = ":0";
  };

  environment.variables.DISPLAY = ":0";

  system.stateVersion = "25.11";
}
```

### Integrate into NixOS (nixos/default.nix)

```nix
# nixos/default.nix
{
  imports = [
    ./hardware-configuration.nix
    ./packages
    "${self}/shared/system"
    ./home
    ./sops.nix
    ./podman.nix
    ./zerotier.nix
    ./sshd.nix
    ./microvm  # 导入 MicroVM host 模块
  ];
  # ... 其他配置
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| QEMU + libvirt | microvm.nix + cloud-hypervisor | 2023-2024 | 更小镜像、更快启动、声明式配置 |
| squashfs boot disk | erofs boot disk | microvm.nix v0.x+ | 更快启动，支持压缩 |
| 手动 virtiofsd | systemd virtiofsd@ service | microvm.nix host 模块 | 自动依赖管理 |

**Deprecated/outdated:**
- 使用 `microvm.balloonMem`：已移除，改用 `microvm.balloon` 布尔选项
- 手动管理 TAP 接口：使用 host 模块的 `microvm-tap-interfaces@` 服务

## Open Questions

1. **Xvfb 在 NixOS guest 中的最佳配置**
   - What we know: Xvfb 提供虚拟 X11 显示
   - What's unclear: 是否需要额外的 Wayland 兼容层支持 Playwright headed 模式
   - Recommendation: Phase 7 实际测试 Playwright headed 模式，必要时添加 wayland-proxy

2. **writable overlay 的 Nix 配置**
   - What we know: overlay 需要挂载到 writable volume
   - What's unclear: 是否需要额外的 Nix 配置来使用 overlay store
   - Recommendation: 参考 microvm.nix 文档，可能需要 `nix.settings.store` 配置

3. **NAT 网络的具体实现**
   - What we know: cloud-hypervisor 不支持 user 网络，必须用 TAP
   - What's unclear: CONTEXT.md 提到的 "NAT 模式" 是否需要额外的 iptables/nftables 配置
   - Recommendation: 使用 TAP 接口但不桥接到物理网络，实现隔离

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | NixOS VM tests (built-in) |
| Config file | None — use `nix build` evaluation |
| Quick run command | `nix build .#nixosConfigurations.nixos.config.microvm.vms.openclaw.config.microvm.declaredRunner` |
| Full suite command | `nix build .#nixosConfigurations.nixos` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| MIC-01 | microvm.nix 集成到 NixOS | build | `nix build .#nixosConfigurations.nixos` | ❌ Wave 0 |
| MIC-02 | MicroVM 可启动 | manual | `systemctl start microvm-openclaw` | ❌ Wave 0 |
| MIC-03 | cloud-hypervisor 作为 hypervisor | build | `nix eval '.#nixosConfigurations.nixos.config.microvm.vms.openclaw.config.microvm.hypervisor'` | ❌ Wave 0 |
| MIC-04 | 2GB 内存分配 | build | `nix eval '.#nixosConfigurations.nixos.config.microvm.vms.openclaw.config.microvm.mem'` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `nix build .#nixosConfigurations.nixos` (eval only, < 30s)
- **Per wave merge:** Full build + MicroVM start test
- **Phase gate:** `nix build` 成功且 MicroVM 可启动

### Wave 0 Gaps
- [ ] `nixos/microvm/default.nix` — host 模块配置
- [ ] `nixos/microvm/openclaw.nix` — guest 配置
- [ ] 更新 `nixos/default.nix` 导入 `./microvm`
- [ ] 验证命令：`nix build .#nixosConfigurations.nixos`

## Sources

### Primary (HIGH confidence)
- [microvm.nix README](https://raw.githubusercontent.com/microvm-nix/microvm.nix/main/README.md) — hypervisor 支持列表，安装指南
- [microvm.nix host.md](https://raw.githubusercontent.com/microvm-nix/microvm.nix/main/doc/src/host.md) — host 模块配置
- [microvm.nix shares.md](https://raw.githubusercontent.com/microvm-nix/microvm.nix/main/doc/src/shares.md) — virtiofs 和 writable overlay
- [microvm.nix interfaces.md](https://raw.githubusercontent.com/microvm-nix/microvm.nix/main/doc/src/interfaces.md) — 网络接口配置
- [microvm.nix options.nix](https://raw.githubusercontent.com/microvm-nix/microvm.nix/main/nixos-modules/microvm/options.nix) — 配置选项定义
- [microvm.nix cloud-hypervisor.nix](https://raw.githubusercontent.com/microvm-nix/microvm.nix/main/lib/runners/cloud-hypervisor.nix) — cloud-hypervisor runner 实现
- [microvm.nix flake-template](https://raw.githubusercontent.com/microvm-nix/microvm.nix/main/flake-template/flake.nix) — 示例配置

### Secondary (MEDIUM confidence)
- WebSearch — cloud-hypervisor 特性确认（不支持 9p，仅 virtiofs）
- WebSearch — Xvfb NixOS 配置模式

### Tertiary (LOW confidence)
- Xvfb systemd 服务配置 — 基于标准 NixOS 模式，未在 microvm.nix 文档中明确提及

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — 直接来自 microvm.nix 官方文档和源码
- Architecture: HIGH — microvm.nix 明确定义的模块结构
- Pitfalls: MEDIUM — 基于文档和实现推断，部分需实际验证

**Research date:** 2026-03-20
**Valid until:** 90 days (microvm.nix 是稳定项目，变更频率低)
