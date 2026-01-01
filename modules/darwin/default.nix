{ pkgs, ... }: {
  # macOS System Defaults
  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.ApplePressAndHoldEnabled = false; # allow keyboard press continuesly
  };

  # TouchID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # Homebrew
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
      "visual-studio-code"
      "cursor"
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
      "telegram"
      "fluent-reader"
      "moonlight"
      
      # Utils
      "balenaetcher"
      "c0re100-qbittorrent"
      "crossover"
      "mos"
      "itermai"
      
      # Fonts
      "font-hack-nerd-font"
      "font-noto-nerd-font"
    ];

    masApps = {
      # "Xcode" = 497799835;
    };
  };

  # macOS-specific system packages that don't belong in shared/system.nix
  environment.systemPackages = with pkgs; [
    # macOS-specific packages if any
    utm # Virtualization software (macOS only)
  ];
}
