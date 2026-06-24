{ pkgs, ... }:
{
  imports = [
    ./ssh.nix
    ./git.nix
    ./tmux
    ./zsh.nix
    ./direnv.nix
    ./opencode.nix
    ./openclaude.nix
    ./codex.nix
    ./uv.nix
    ./helix.nix
  ];

  home = {
    packages = with pkgs; [
      jupyter-all
    ];
    username = "zhaochanglong";
    stateVersion = "24.05";
  };

  home.sessionPath = [ "$HOME/.local/bin" ];
}
