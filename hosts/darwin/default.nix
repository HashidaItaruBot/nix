{ pkgs, ... }: {
  imports = [
    ../../configuration.nix
    ../../packages/darwin.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = "zhaochanglong";

  nix.enable = false;
  
  users.users.zhaochanglong = {
    name = "zhaochanglong";
    home = "/Users/zhaochanglong";
  };
  
  home-manager.users.zhaochanglong = {
    home.homeDirectory = "/Users/zhaochanglong";
  };

  system.stateVersion = 5;

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
