{
  self,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./packages
    "${self}/shared/system"
    ./home
    ./sops.nix
  ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Shanghai";
  networking.timeServers = [
    "ntp.aliyun.com"
    "ntp.tuna.tsinghua.edu.cn"
    "0.nixos.pool.ntp.org"
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.thermald.enable = true; # 启用温度管理
  services.power-profiles-daemon.enable = true; # 启用电源模式切换
  services.logind.settings.Login = {
    IdleAction = "ignore"; # 禁用空闲时的操作（不关机、不休眠、不挂起）
    HandlePowerKey = "suspend"; # 按下电源按钮后挂起
  };

  # Enable PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # mihomo configuration
  services.mihomo = {
    enable = false;
    configFile = config.sops.secrets.mihomo_config.path;
    tunMode = true;
    webui = pkgs.metacubexd;
  };

  virtualisation.waydroid.enable = true;

  services.blueman.enable = true;

  powerManagement.cpuFreqGovernor = "performance"; # 强制 CPU 模式为高性能

  # Fonts configuration
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      monospace = [
        "Sarasa Mono SC"
        "Noto Sans Mono CJK SC"
      ];
      sansSerif = [
        "Sarasa Term SC"
        "Noto Sans CJK SC"
      ];
      serif = [ "Noto Serif CJK SC" ];
    };
    antialias = true;
    hinting.enable = true;
    subpixel.lcdfilter = "default";
  };

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

  environment.variables = {
    GTK_IM_MODULE = lib.mkForce "";
    QT_IM_MODULE = lib.mkForce "";
  };

  # Define a user account.
  users.users.zhaochanglong = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "docker"
    ];
  };

  # Docker configuration
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
    daemon.settings = { };
  };

  system.stateVersion = "25.11";
}
