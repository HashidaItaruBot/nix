{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  # nixvim 自建 nixpkgs 实例，看不到仓库 packages/default.nix 的本地包。
  # 把官方 flake 构建的 opencode 注入 nixvim 环境，
  # agentic.nix 以裸命令 "opencode" 从 PATH 解析（ACP 子进程继承该 PATH）。
  programs.nixvim.extraPackages = [
    inputs.opencode.packages.${pkgs.system}.opencode
  ];

  programs.nixvim = {
    enable = true;

    # nixvim instantiates its own nixpkgs; system allowUnfree does not apply.
    nixpkgs.config.allowUnfree = true;

    imports = [
      ./config
    ];
  };
}
