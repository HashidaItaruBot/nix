{ ... }: {

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };

    taps = [
    ];

    brews = [
    ];

    casks = [
      # Browsers
      "google-chrome"

      # Dev Tools
      "cursor"
      "visual-studio-code"
      "alacritty"

      # Terminal
      "iterm2"
      "warp"

      # System Tools
      "1password"
      "docker-desktop"
      "zerotier-one"

      # Docs & Notes
      "obsidian"
      "zotero"

      # Media
      "vlc"
      "elmedia-player"
      "telegram-desktop"
      "fluent-reader"
      "moonlight"

      # Utils
      "balenaetcher"
      "qbittorrent"
      "crossover"
      "mos"
      "itermai"
      "utm"
      "ghostty"
      "zed"
      "thunderbird"
    ];
  };
}
