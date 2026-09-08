{
  pkgs,
  inputs,
  ...
}: let
  nipaplay-reload = pkgs.callPackage ./nipaplay-appimage.nix {};
  ecc-universal = pkgs.callPackage ./ecc-universal.nix {};
  langcli = pkgs.callPackage ./langcli.nix {};
  reasonix = pkgs.callPackage ./reasonix.nix {};
  codegraph = pkgs.callPackage ./codegraph.nix {};
in {
  imports = [
    ./flatpak.nix
    ./podman.nix
    ./hyprland.nix
    ./ccache.nix
    ./coolercontrol.nix
    ./wivrn.nix
    ./nix-ld.nix
  ];

  environment.systemPackages = with pkgs; [
    # Core CLI tools
    bubblewrap
    vim
    git
    gh
    github-copilot-cli
    copilot-language-server
    tree
    wget
    htop
    aria2
    fd
    fzf
    ripgrep
    lazygit
    zoxide
    bat

    # Development
    gnumake
    gcc
    clang
    clang-tools
    cmake
    nodejs
    ecc-universal
    langcli
    reasonix
    codegraph
    openspec
    pnpm
    metals
    gdb

    # System tools
    qemu
    nh
    ssh-to-age
    sops
    openssh

    # Nix tools
    nixd
    nil
    alejandra
    statix
    nom
    protontricks

    # Python tools
    ruff

    logisim-evolution
    yazi

    # Desktop apps
    vscodium
    code-cursor
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
    unrar
    p7zip
    unar
    ppsspp-sdl-wayland
    appimage-run
    nipaplay-reload
    podman-desktop
    thunderbird
    chromium
    tor-browser
    aider-chat-full
    discord
    gnome-network-displays
    drawio
    zotero
    valgrind
    obs-studio
    lm_sensors
    liquidctl # USB AIOs、水冷、风扇集线器支持
    intiface-central
    cursor-cli
    marktext
    gittyup
    wl-clipboard
    cliphist
    jupyter-all
    gtkwave
  ];

  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = ["zhaochanglong"];
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
