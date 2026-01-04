{ pkgs, ... }: {

  imports = [
    ./homebrew.nix
  ];
  environment.systemPackages = with pkgs; [
    # macOS specific packages
    iterm2
    utm
  ];
}

