{
  pkgs,
  inputs,
  ...
}:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # 默认开启 tmux 自动启动，在 VS Code / Zed 中自动关闭
    initContent = ''
      ZSH_TMUX_AUTOSTART=true
      ZSH_TMUX_AUTOCONNECT=true

      if [ "$TERM_PROGRAM" = "vscode" ]; then
        ZSH_TMUX_AUTOSTART=false
      fi

      if [ "$ZED_TERM" = "true" ] || [ "$TERM_PROGRAM" = "Zed" ]; then
        ZSH_TMUX_AUTOSTART=false
      fi
    '';

    shellAliases = {
      ll = "ls -l";
    };
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "podman"
        "tmux"
      ];
    };
  };
}
