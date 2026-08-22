{...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    envExtra = ''
      if [[ "$XDG_CURRENT_DESKTOP" == *"KDE"* \
        && "$TERM_PROGRAM" != "vscode" \
        && -z "$ZED_TERM" ]]; then
        export ZSH_TMUX_AUTOSTART=true
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
        "vi-mode"
        "zoxide"
        "zsh-interactive-cd"
        "zsh-navigation-tools"
      ];
    };
  };
}
