{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    kdePackages.kate
    kdePackages.dolphin
    firefox
    _1password-cli
    code-cursor
    alacritty
    obsidian
    telegram-desktop
    vlc
    qbittorrent
    steam
  ];

}

