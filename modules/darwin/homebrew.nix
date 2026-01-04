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
      # visual-studio-code moved to nix
      # cursor moved to nix (code-cursor)
      # alacritty moved to nix
      
      # Terminal
      # iterm2 moved to nix
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
      
      # Fonts
      # fonts moved to nix
    ];

    masApps = {
      # "Xcode" = 497799835;
    };
  };
}

