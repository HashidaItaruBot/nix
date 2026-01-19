{ pkgs, ... }:
{
  imports = [
    ./flatpak.nix
  ];
  
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
    qq
    protonup-qt
    pciutils
    heroic
    mangohud
    netease-cloud-music-gtk
    waydroid-helper
  ];

  programs._1password.enable = true;
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

