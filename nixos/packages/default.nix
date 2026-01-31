{ pkgs, inputs, ... }:
{
  imports = [
    ./flatpak.nix
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

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      github.copilot
      github.codespaces
      github.copilot-chat
      github.github-vscode-theme
      github.vscode-github-actions
      github.vscode-pull-request-github
    ];
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # 允许 Sunshine 捕获屏幕和模拟输入
    openFirewall = true; # 自动打开必要的端口 (47984-48010 等)
  };
}
