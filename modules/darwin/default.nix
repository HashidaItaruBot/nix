{ pkgs, ... }: {

  imports = [
    ./homebrew.nix
  ];
  environment.systemPackages = with pkgs; [
    iterm2
    utm
  ];
}

