{ inputs, pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    mouse = true;
    shortcut = "a"; # prefix key
  };
}
