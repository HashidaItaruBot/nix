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

      if [ "$TERM_PROGRAM" = "vscode" ]; then
        ZSH_TMUX_AUTOSTART=false
      fi

      if [ "$ZED_TERM" = "true" ] || [ "$TERM_PROGRAM" = "Zed" ]; then
        ZSH_TMUX_AUTOSTART=false
      fi
    '';

    shellAliases = {
      ll = "ls -l";
      # nom aliases for better build output
      nb = "nom build";
      ns = "nom build . && sudo nixos-rebuild switch --flake .";
      nd = "nom build . && darwin-rebuild switch --flake .";
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
