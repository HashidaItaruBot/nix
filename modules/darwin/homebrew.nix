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
      # obsidian moved to nix
      "zotero"
      
      # Media
      # vlc moved to nix
      "elmedia-player"
      # telegram moved to nix
      "fluent-reader"
      "moonlight"
      
      # Utils
      "balenaetcher"
      # qbittorrent moved to nix
      "crossover"
      "mos"
      "itermai"
      "utm"
    ];

    masApps = {
      # "Xcode" = 497799835;
    };
  };
}

