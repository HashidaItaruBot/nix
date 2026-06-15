{
  self,
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    "${self}/shared/home"
    ./git.nix
    ./ssh.nix
    ./vscode.nix
    ./zed.nix
    ./kitty.nix
    ./hyprland
    ./nixvim
    ./1password.nix
    ./appimage.nix
    ./podman
  ];

  home.homeDirectory = "/home/zhaochanglong";

  programs.ghostty = {
    enable = true;
    settings = {
      font-size = 18;
      font-family = "Hack Nerd Font";
      window-decoration = true;
      confirm-close-surface = false;
      maximize = true;
    };
  };
}
