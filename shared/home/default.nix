{pkgs, ...}: {
  imports = [
    ./ssh.nix
    ./git.nix
    ./tmux
    ./zsh.nix
    ./direnv.nix
    ./opencode.nix
    ./claude-code.nix
  ];

  home.packages = with pkgs; [
    jupyter-all
  ];

  home.username = "zhaochanglong";

  home.stateVersion = "24.05";
}
