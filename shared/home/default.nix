{ pkgs, inputs, ... }:
{
  imports = [
    ./kitty.nix
    ./ssh.nix
    ./git.nix
    ./tmux
    ./nixvim.nix
    ./vscode.nix
    ./zsh.nix
  ];

  home.username = "zhaochanglong";

  home.stateVersion = "24.05";
}
