{
  pkgs,
  inputs,
  ...
}: let
  # zcode-cli 依赖 pnpm_10 >= 10.34.5（stable 的 10.34.0 被 nixpkgs 标记 CVE-2026-55487 等）
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in {
  home.packages = [
    (unstable.callPackage ./../packages/zcode-cli.nix {})
  ];
}
