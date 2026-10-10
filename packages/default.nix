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
  oh-my-pi = pkgs.callPackage ./oh-my-pi.nix {};
  # OpenCode v2: 官方 flake 源码构建 (github:anomalyco/opencode @ v2.0.26)
  opencode-v2 = inputs.opencode-v2.packages.${pkgs.system}.opencode;
  opencode-desktop-v2 = inputs.opencode-v2.packages.${pkgs.system}.opencode-desktop;
in {
  imports = [
    ./flatpak.nix
    ./podman.nix
    ./hyprland.nix
    ./ccache.nix
    ./coolercontrol.nix
    ./wivrn.nix
    ./nix-ld.nix
    ./zerotier.nix
    ./waydroid.nix
  ];

  environment.systemPackages = with pkgs; [
    # Core CLI tools
    bubblewrap
    vim
    git
    gh
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
    pi-coding-agent
    opencode-v2
    opencode-desktop-v2
    oh-my-pi
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
