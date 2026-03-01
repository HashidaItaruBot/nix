{ pkgs, ... }:
{
  imports = [
    ./ssh.nix
    ./git.nix
    ./tmux
    ./zsh.nix
    ./direnv.nix
    ./opencode.nix  # 添加opencode配置
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  home.packages = with pkgs; [
    jupyter-all
  ];

  home.username = "zhaochanglong";

  home.stateVersion = "24.05";
}
