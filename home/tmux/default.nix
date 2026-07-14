{pkgs, ...}: let
  oh-my-tmux = pkgs.fetchFromGitHub {
    owner = "gpakosz";
    repo = ".tmux";
    rev = "af33f07134b76134acca9d01eacbdecca9c9cda6";
    hash = "sha256-nXm664l84YSwZeRM4Hsweqgz+OlpyfwXcgEdyNGhaGA=";
  };
in {
  programs.tmux = {
    enable = true;
    # 必须禁用 Home Manager 默认开启的 sensible 插件，以防与 Oh My Tmux 的内置逻辑冲突 [2]
    sensibleOnTop = false;
  };

  xdg.configFile."tmux/tmux.conf".source = "${oh-my-tmux}/.tmux.conf";

  xdg.configFile."tmux/tmux.conf.local".source = ./tmux.conf.local;
}
