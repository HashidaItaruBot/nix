{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mas
  ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };

    taps = [
    ];

    casks = [
      # Browsers
      "google-chrome"

      # Dev Tools
      "cursor"
      "visual-studio-code"
      "zed"

      # Terminal
      "iterm2"
      "warp"
      "alacritty"
      "kitty"

      # System Tools
      "1password"
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
      "clash-verge-rev"
      "moonlight"
      "steam"
      "codex-app"
      "tencent-meeting"
      "ungoogled-chromium"
      "zen"
      "mark-text"
    ];
  };
}
