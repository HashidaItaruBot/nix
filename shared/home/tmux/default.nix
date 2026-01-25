{ inputs, pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    # 开启鼠标支持等基础配置
    mouse = true;
    shortcut = "a"; # 习惯用的前缀键，oh-my-tmux 默认也是 C-a

    extraConfig = ''
      # 1. 显式设置 shell，防止 oh-my-tmux 使用默认的 /bin/sh
      set -g default-shell ${pkgs.zsh}/bin/zsh  # 或者 pkgs.bash

      # 2. 注入核心工具路径到 tmux 内部环境
      set-environment -g PATH "/run/current-system/sw/bin:$PATH"
      source-file ${inputs.oh-my-tmux}/.tmux.conf
    '';
  };

  # 如果你想让 oh-my-tmux 自动生成的 .tmux.conf.local 也在 Nix 管理下
  # 你可以把它的示例文件复制出来并进行个性化修改
  home.file.".tmux.conf.local".source = ./tmux.conf.local;
}
