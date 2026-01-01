{ pkgs, ... }: {
  # Fonts configuration
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      sarasa-gothic
      corefonts
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
    ];

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
  
  environment.systemPackages = with pkgs; [
    # Linux specific packages 
    # (Common packages have been moved to shared/system.nix)
    
    # GUI apps that were system packages in linux config
    telegram-desktop
    code-cursor
  ];
}
