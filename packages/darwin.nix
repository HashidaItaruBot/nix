{ pkgs, ... }: {

  imports = [
    ./brew.nix
  ];
  environment.systemPackages = with pkgs; [
    # macOS specific packages
    iterm2
    utm
  ];
}

