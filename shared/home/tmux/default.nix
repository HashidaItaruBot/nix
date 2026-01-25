{ pkgs, ... }:

let
  oh-my-tmux = pkgs.fetchFromGitHub {
    owner = "gpakosz";
    repo = ".tmux";
    rev = "87dcd13a28aeb5f18baee630e24b3f5765ae3a4f";
    hash = "sha256-rfJkL4EMMunbC7wGiw7O/1E/0XTzA2N+RR7gXEoalAY=";
  };
in
{
  programs.tmux = {
    enable = true;
    # 必须禁用 Home Manager 默认开启的 sensible 插件，以防与 Oh My Tmux 的内置逻辑冲突 [2]
    sensibleOnTop = false;
  };

  xdg.configFile."tmux/tmux.conf".source = "${oh-my-tmux}/.tmux.conf";

  xdg.configFile."tmux/tmux.conf.local".source = ./tmux.conf.local;
}
