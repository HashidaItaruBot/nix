{
  pkgs,
  inputs,
  ...
}:
let
  nipaplay-reload = pkgs.callPackage ./nipaplay-reload/package.nix { };
in
{
  imports = [
    ./flatpak.nix
    ./podman.nix
    ./incus
  ];

  environment.systemPackages = with pkgs; [
    kdePackages.kate
    kdePackages.dolphin
    firefox
    alacritty
    obsidian
    telegram-desktop
    vlc
    qbittorrent-enhanced
    qq
    protonup-qt
    pciutils
    mangohud
    netease-cloud-music-gtk
    waydroid-helper
    unrar
    p7zip
    unar
    ppsspp-sdl-wayland
    appimage-run
    podman-desktop
    thunderbird
    chromium
    librewolf
    tor-browser
    aider-chat-full
    nipaplay-reload
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
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

  services.redshift.enable = true;
  location.provider = "geoclue2";
}
