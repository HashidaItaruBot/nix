{ pkgs, inputs, ... }:
{
  imports = [
    ./flatpak.nix
    ./ollama.nix
  ];

  environment.systemPackages = with pkgs; [
    kdePackages.kate
    kdePackages.dolphin
    firefox
    code-cursor
    alacritty
    obsidian
    telegram-desktop
    vlc
    qbittorrent-enhanced
    qq
    protonup-qt
    pciutils
    heroic
    mangohud
    netease-cloud-music-gtk
    waydroid-helper
    unrar
    p7zip
    unar
    ppsspp-sdl-wayland

    # Nix开发工具
    nixd
    nixpkgs-fmt
    nil

    # AI/ML工具
  ];

  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "zhaochanglong" ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # 远程串流
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # 允许 Sunshine 捕获屏幕和模拟输入
    openFirewall = true; # 自动打开必要的端口 (47984-48010 等)
  };
}
