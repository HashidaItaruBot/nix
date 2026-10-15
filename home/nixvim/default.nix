{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  # pi-acp: ACP (Agent Client Protocol) ↔ `pi --mode rpc` 桥。
  # agentic.nix 以裸命令 "pi-acp" 从 PATH 解析（ACP 子进程继承该 PATH）。
  # pi 二进制来自系统包 pi-coding-agent，适配器只 spawn 它，不需要在这里注入。
  programs.nixvim.extraPackages = [
    (pkgs.callPackage ../../packages/pi-acp.nix { })
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
