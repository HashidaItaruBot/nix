{
  self,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./overlays
    ./zram.nix
    ./packages
    ./home
    ./sops.nix
    ./sshd.nix
    ./firewall.nix
  ];

  networking = {
    networkmanager.enable = true;
    timeServers = [
      "ntp.aliyun.com"
      "ntp.tuna.tsinghua.edu.cn"
      "0.nixos.pool.ntp.org"
    ];
  };

  time.timeZone = "Asia/Shanghai";

  services = {
    xserver.enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
    power-profiles-daemon.enable = true; # 启用电源模式切换
    logind.settings.Login = {
      IdleAction = "ignore"; # 禁用空闲时的操作（不关机、不休眠、不挂起）
      HandlePowerKey = "suspend"; # 按下电源按钮后挂起
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    mihomo = {
      enable = false;
      configFile = config.sops.secrets.mihomo_config.path;
      tunMode = true;
      webui = pkgs.metacubexd;
    };
    blueman.enable = true;
  };

  # Enable PipeWire
  security.rtkit.enable = true;

  powerManagement.cpuFreqGovernor = "performance"; # 强制 CPU 模式为高性能

  # Fonts configuration
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      emoji = ["Noto Color Emoji"];
      monospace = [
        "Sarasa Mono SC"
        "Noto Sans Mono CJK SC"
      ];
      sansSerif = [
        "Sarasa Term SC"
        "Noto Sans CJK SC"
      ];
      serif = ["Noto Serif CJK CJK"];
    };
    antialias = true;
    hinting.enable = true;
    subpixel.lcdfilter = "default";
  };

  fonts.packages = with pkgs; [
    wqy_microhei
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    sarasa-gothic
    corefonts
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    nerd-fonts.hack
    nerd-fonts.noto
  ];

  # Input Method
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-chinese-addons
      fcitx5-rime
      qt6Packages.fcitx5-configtool
      fcitx5-gtk
      fcitx5-material-color
    ];
  };

  programs.zsh.enable = true;
  programs._1password.enable = true;

  environment.variables = {
    GTK_IM_MODULE = lib.mkForce "";
    QT_IM_MODULE = lib.mkForce "";
  };

  # Define a user account.
  users.users.zhaochanglong = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "dialout"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5M2RGhIG1CslAdzx+1xcOFiAgJhw0FKFqhe/Wkm1qZ"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  nix = {
    channel.enable = false;
    gc = {
      automatic = true;
      persistent = true;
      dates = "02:00";
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;
    package = pkgs.lixPackageSets.stable.lix;
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  system.stateVersion = "25.11";
}
