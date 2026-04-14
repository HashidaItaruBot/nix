{ pkgs, ... }:
{
  imports = [
    ./ssh.nix
    ./git.nix
    ./tmux
    ./zsh.nix
    ./direnv.nix
    ./opencode.nix
    ./claude-code.nix
    ./codex.nix
    ./uv.nix
  ];

  home = {
    packages = with pkgs; [
      jupyter-all
    ];
    username = "zhaochanglong";
    stateVersion = "24.05";
  };
}
