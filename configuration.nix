{ pkgs, inputs, ... }: {
  imports = [
    ./packages/common.nix
  ];

  # Common system configuration
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}

