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
}

