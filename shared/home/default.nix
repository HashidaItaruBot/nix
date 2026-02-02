{ pkgs, inputs, ... }:
{
  imports = [
    ./kitty.nix
    ./ssh.nix
    ./git.nix
    ./tmux
    ./zsh.nix
    ./direnv.nix
    ./texlive.nix
  ];

  home.username = "zhaochanglong";

  home.stateVersion = "24.05";
}
