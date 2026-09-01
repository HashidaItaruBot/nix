## Context

本仓库是 NixOS + home-manager 声明式配置，已有 Helix、Zed、VS Code 等编辑器配置。用户希望新增 Neovim 支持，参考 [kickstart.nixvim](https://github.com/JMartJonesy/kickstart.nixvim) 的模块化方案。

kickstart.nixvim 的核心设计：
- 单一 `nixvim.nix` 包含全局选项 + `imports` 引入各插件模块
- `config/plugins/kickstart/` 每插件一文件
- `config/plugins/custom/` 用户扩展点
- 支持 standalone flake 和 home-manager/nixos module 两种消费方式

本仓库采用 home-manager 集成方式（与 kickstart.nixvim 的 `homeManagerModules.default` 等效），不单独提供 standalone flake package。

当前 `home/nixvim/` 目录已有初步实现，本变更将其规范化、补全并验证构建。

## Goals / Non-Goals

**Goals:**

- 提供基于 kickstart.nixvim 的模块化 nixvim 脚手架
- 默认启用核心开发体验（LSP、补全、搜索、格式化、语法高亮）
- 可选插件通过取消注释即可启用，零代码改动
- 自定义插件有清晰扩展路径和文档
- 与现有 flake 版本策略一致（`nixos-26.05`）

**Non-Goals:**

- 不提供 standalone `nix run` 入口（本仓库非 nixvim 发行版）
- 不替换或移除 Helix/Zed 配置
- 不预装语言专用 LSP（除 nil_ls/lua_ls 外），用户按需扩展
- 不实现 CI nixvim check（可后续添加）

## Decisions

### 1. 集成方式：home-manager module

**选择**: 在 `home/nixvim/default.nix` 中 `imports = [ inputs.nixvim.homeModules.nixvim ]` + `programs.nixvim.enable = true`

**理由**: 与仓库现有 home-manager 模式一致（helix.nix、zed.nix 等），无需额外 flake outputs。

**替代方案**:
- kickstart.nixvim 的 standalone flake + `makeNixvimWithModule` — 适合独立项目，不适合嵌入 NixOS 配置
- NixOS 系统级 `programs.nixvim` — 本配置为用户级，home-manager 更合适

### 2. 目录结构：扁平化 kickstart 布局

```
home/nixvim/
├── default.nix          # 入口：enable + imports
├── options.nix          # 全局选项（从 kickstart nixvim.nix 提取）
├── keymaps.nix          # 基础键位
└── plugins/
    ├── default.nix      # 插件聚合
    ├── kickstart/       # 上游 kickstart 插件（每插件 .nix）
    └── custom/          # 用户自定义插件 + README
```

**理由**: 与 kickstart.nixvim 一一对应，降低从上游同步的难度。将 kickstart 的 `nixvim.nix` 拆为 `options.nix` + `keymaps.nix` 提高可读性。

**替代方案**:
- 单文件 `nixvim.nix`（kickstart 原始方案）— 文件过长（300+ 行），不利于维护

### 3. 插件模块模式：纯属性集

每个插件文件导出 nixvim 模块属性集，例如：

```nix
# plugins/kickstart/telescope.nix
{
  plugins.telescope = {
    enable = true;
  };
}
```

**理由**: kickstart.nixvim 已验证此模式；每个文件自包含，可独立启用/禁用/覆盖。

### 4. nixvim 版本：nixos-26.05

```nix
nixvim.url = "github:nix-community/nixvim/nixos-26.05";
```

**理由**: 与 `nixpkgs`（`nixos-26.05`）和 `home-manager`（`release-26.05`）版本对齐，避免 API 不兼容。

### 5. Nerd Font 默认启用

`globals.have_nerd_font = true`，与仓库终端配置（Ghostty 使用 Hack Nerd Font）一致。

kickstart.nixvim 默认 `enable_nerd_fonts = false`；本仓库覆盖为 `true`。

### 6. 自定义插件扩展三层

| 层级 | 方式 | 适用场景 |
|------|------|----------|
| L1 | `plugins.<name>.enable` | nixvim 已封装的插件 |
| L2 | `extraPlugins` + `extraConfigLua` | nixpkgs 有但未封装的 vim 插件 |
| L3 | `extraConfigLuaPost` | 全局 Lua 初始化代码 |

在 `plugins/custom/README.md` 中提供三种模式的示例模板。

## Risks / Trade-offs

| 风险 | 缓解 |
|------|------|
| nixvim API 随版本变化，插件选项可能失效 | 锁定 `nixos-26.05` 分支；升级时对照 nixvim changelog |
| kickstart 上游更新需手动同步 | kickstart/ 目录保持与上游文件一一对应，便于 diff |
| LSP 服务器需额外 systemPackages | conform/nil_ls 等 formatter/LSP 二进制由 nixvim 模块自动处理；特殊语言需用户自行添加 |
| 与 Helix 配置功能重叠 | 两者并存，用户自由选择；不强制迁移 |
| 构建时间较长（treesitter 编译） | 首次构建慢，后续有 substituter 缓存；可用 `nixos-rebuild build` 先验证 |

## Migration Plan

1. 确认 `flake.nix` 含 `nixvim` input
2. 创建/完善 `home/nixvim/` 全部模块文件
3. `home/zhaochanglong.nix` 添加 `import ./nixvim`（如未添加）
4. `git add` 所有新文件
5. `nixos-rebuild build --flake .#<hostname>` 验证
6. `sudo nixos-rebuild switch --flake .#<hostname>` 应用
7. 运行 `nvim` + `:checkhealth` 验证

**回滚**: 从 `home/zhaochanglong.nix` 移除 `./nixvim` import 并 rebuild，不影响其他编辑器。

## Open Questions

- 是否在 CI（`.github/workflows/ci.yml`）中添加 nixvim 构建检查？（建议后续变更处理）
- 是否需要为特定语言（Rust、Python、TypeScript）预配置 LSP servers？（当前仅 nil_ls + lua_ls，用户按需扩展）
