{ self
, inputs
, config
, lib
, pkgs
, ...
}: {
  imports = [
    "${self}/shared/home"
    inputs.plasma-manager.homeModules.plasma-manager
    ./git.nix
    ./ssh.nix
    ./vscode.nix
    ./zed.nix
    ./ollama.nix
    ./kitty.nix
    ./nixvim
    ./1password.nix
    ./appimage.nix
    ./podman
  ];

  home.homeDirectory = "/home/zhaochanglong";

  # 登录后自动锁屏
  xdg.configFile."autostart/lock-screen.desktop" = {
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Lock Screen on Login
      Exec=sh -c "loginctl lock-session"
      Icon=system-lock-screen
      Terminal=false
      X-KDE-autostart-phase=2
    '';
  };

  services.linux-wallpaperengine = {
    enable = true;
    assetsPath = config.home.homeDirectory + "/.local/share/Steam/steamapps/workshop/content/431960";
    wallpapers = [
      {
        monitor = "DP-3"; # 显示器名称
        wallpaperId = "823335782";
      }
    ];
  };

  programs.ghostty = {
    enable = true;
    settings = {
      font-size = 18;
      font-family = "Hack Nerd Font";
      window-decoration = true;
      confirm-close-surface = false;
      maximize = true;
    };
  };

  programs.plasma = {
    enable = true;
    hotkeys.commands = {
      "launch-ghostty" = {
        name = "Launch Ghostty";
        key = "Ctrl+Alt+T";
        command = "ghostty";
      };
    };
    # 锁屏配置
    kscreenlocker = {
      lockOnResume = true;
      timeout = 5; # 5分钟无操作后锁屏
    };
  };
}
