{
  self,
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
    ./git.nix
    ./ssh.nix
    ./tmux
    ./zsh.nix
    ./direnv.nix
    ./opencode.nix
    ./openclaude.nix
    ./codex.nix
    ./uv.nix
    ./helix.nix
    ./zed.nix
    ./kitty.nix
    ./config
    ./1password.nix
    ./appimage.nix
    ./podman
  ];

  home = {
    username = "zhaochanglong";
    homeDirectory = "/home/zhaochanglong";
    stateVersion = "24.05";
    sessionPath = ["$HOME/.local/bin"];
    packages = with pkgs; [
      jupyter-all
    ];
  };

  services.linux-wallpaperengine = {
    enable = true;
    assetsPath = config.home.homeDirectory + "/.local/share/Steam/steamapps/workshop/content/431960";
    wallpapers = [
      {
        monitor = "DP-3"; # 显示器名称
        wallpaperId = "3560116299";
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
