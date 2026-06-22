{ pkgs, self, ... }: {
  home.packages = [
    (pkgs.callPackage "${self}/shared/packages/openclaude.nix" { })
  ];
}
