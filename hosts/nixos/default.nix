{ config, lib, pkgs, ... }: {
  imports = [
    ../../configuration.nix
    ../../packages/nixos.nix
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
  
  # Enable PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Fonts configuration
  # fonts.packages are imported from packages/common.nix
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [ "Sarasa Mono SC" "Noto Sans Mono CJK SC" ];
        sansSerif = [ "Sarasa Term SC" "Noto Sans CJK SC" ];
        serif = [ "Noto Serif CJK SC" ];
      };
      antialias = true;
      hinting.enable = true;
      subpixel.lcdfilter = "default";
    };
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
    XMODIFIERS = "@im=fcitx";
    QT_IM_MODULE = "fcitx";
    GTK_IM_MODULE = "fcitx";
  };

  # Define a user account.
  users.users.zhaochanglong = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    packages = with pkgs; [
      kdePackages.kate
      kdePackages.dolphin
      firefox
      _1password-cli
    ];
  };
  
  home-manager.users.zhaochanglong = {
    home.homeDirectory = "/home/zhaochanglong";
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "zhaochanglong" ];
  };
  
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";
}
