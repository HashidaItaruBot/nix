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
    ./zerotier.nix
    ./sshd.nix
    ./containers # OpenHands NixOS 容器配置
  ];

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    timeServers = [
      "ntp.aliyun.com"
      "ntp.tuna.tsinghua.edu.cn"
      "0.nixos.pool.ntp.org"
    ];
  };

  time.timeZone = "Asia/Shanghai";

  # Enable the X11 windowing system.
  services = {
    xserver.enable = true;
    displayManager = {
      sddm.enable = true;
      autoLogin = {
        enable = true;
        user = "zhaochanglong";
      };
    };
    desktopManager.plasma6.enable = true;
    thermald.enable = true; # 启用温度管理
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
      "containers" # 允许管理 NixOS 容器
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5M2RGhIG1CslAdzx+1xcOFiAgJhw0FKFqhe/Wkm1qZ"
    ];
  };

  system.stateVersion = "25.11";
}
