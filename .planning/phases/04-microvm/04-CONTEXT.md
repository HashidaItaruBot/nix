# Phase 4: MicroVM 基础设施 - Context

**Gathered:** 2026-03-20
**Status:** Ready for planning

<domain>
## Phase Boundary

在 NixOS 宿主机上配置 MicroVM 基础设施，使用 cloud-hypervisor 运行 OpenClaw NixOS guest。guest 通过 NAT 模式网络隔离，仅宿主机可访问 openclaw 服务。

</domain>

<decisions>
## Implementation Decisions

### A. 配置组织方式

| 决策 | 配置 |
|------|------|
| A1 | 创建独立的 `nixos/microvm.nix` 文件（宿主机导入） |
| A2 | 创建 `nixos/microvm/` 目录，`default.nix` 为 host 配置，`openclaw.nix` 为 guest 配置 |
| A3 | OpenClaw 通过 nix-openclaw home-manager 模块在 guest 内部部署 |
| A4 | 多文件结构，每个 MicroVM 独立子目录 |

**目录结构**：
```
nixos/microvm/
├── default.nix         # Host 配置：导入 microvm.nixosModules.host
└── openclaw.nix        # Guest 配置：定义 openclaw VM
```

### B. Hypervisor 配置

| 决策 | 配置 |
|------|------|
| Hypervisor | cloud-hypervisor |
| 内存 | 2GB |
| CPU | 2 vCPU |
| 控制 socket | 默认配置（优雅关闭） |
| vhost | 默认启用 |

### C. 网络配置

| 决策 | 配置 |
|------|------|
| 模式 | **NAT 模式**（仅 host 访问） |
| 宿主机网络 | 保持现状（不需要 systemd-networkd 桥接） |
| MAC 地址 | 自动生成 |
| Guest IP | DHCP（内部网 10.0.2.x） |

### D. Guest 镜像配置

| 决策 | 配置 |
|------|------|
| D1 | MicroVM without OSD（最小化镜像） |
| D2 | `imageType = "tiny"`（~50MB） |
| D3 | 预装工具：`git`, `curl`, `wget`, `vim`, `nodejs_22`, `python3`, `gcc`, `make`, `jq`, `htop`, `xvfb` |
| D4 | 仅通过 `microvm-console` 访问，无密码 |
| D5 | `writable overlay = true`（支持 Playwright 浏览器下载） |
| D6 | Xvfb 无头图形环境（用于 Playwright headed 模式） |

### 安全约束

**Guest 无法修改宿主机文件的保证**：

```nix
microvm.shares = [{
  proto = "virtiofs";
  tag = "ro-store";
  source = "/nix/store";
  mountPoint = "/nix/.ro-store";
  readonly = true;  # 显式只读，guest 无法写入宿主机
}];

microvm.writable = true;  # writable overlay 仅作用于 guest 镜像内部
# 所有 guest 写入都存储在 /var/lib/microvms/openclaw/ 下的镜像文件中
# 删除 guest 后，所有写入消失，不影响宿主机
```

**隔离保证**：
1. virtiofs 显式配置 `readonly = true` — guest 只能读取 `/nix/store`
2. writable overlay 作用范围仅限于 guest 镜像文件
3. NAT 模式网络隔离 — guest 无法主动访问宿主机网络
4. 不配置其他共享目录 — 仅共享 `/nix/store`

</decisions>

<specifics>
## Specific Ideas

- 使用 cloud-hypervisor 而非 qemu：更轻量、启动更快、Rust 内存安全、microvm.nix 集成更好
- 使用 virtiofs 共享 `/nix/store`：guest 镜像小巧，复用宿主机已构建的 Nix 包
- writable overlay 支持 Playwright 浏览器二进制文件下载（运行时动态安装）
- Xvfb 提供无头图形环境，支持 Playwright headed 模式测试

</specifics>

<canonical_refs>
## Canonical References

### 需求追踪
- `REQUIREMENTS.md` — MIC-01 ~ MIC-04 需求定义
- `ROADMAP.md` — Phase 4 范围边界

### 技术参考
- `STACK.md` — cloud-hypervisor 推荐依据
- `ARCHITECTURE.md` — MicroVM 宿主机/客户机架构

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `flake.nix` — microvm.nix 已作为 input 引入
- `nixos/default.nix` — 宿主机主配置，需导入 `./microvm`
- `nixos/packages/` — 可添加 MicroVM 相关工具包

### Established Patterns
- 模块导入模式：`imports = [ ./microvm ];`
- 使用 `microvm.nixosModules.host` 和 `microvm.nixosModules.microvm`

### Integration Points
- microvm.nix 的 host 模块在宿主机创建 systemd 服务和 TAP 接口
- guest 配置中启用 home-manager 和 nix-openclaw 模块
- Xvfb 在 guest 内部运行，支持 Playwright 浏览器

</code_context>

<deferred>
## Deferred Ideas

- 未来扩展：添加第二个 MicroVM 时，在 `nixos/microvm/` 下创建新子目录
- 未来扩展：如果需要 LAN 访问 openclaw，可改用桥接模式
- 未来扩展：如果需要完整图形界面，可配置 virtio-gpu + VNC

</deferred>

---

*Phase: 04-microvm*
*Context gathered: 2026-03-20*
