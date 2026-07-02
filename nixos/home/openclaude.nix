{pkgs, ...}: {
  home.packages = [
    (pkgs.callPackage ./../packages/openclaude.nix {})
  ];
}
