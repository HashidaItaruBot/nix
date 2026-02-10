{
  self,
  inputs,
  config,
  ...
}:
{
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
  ];

  home.homeDirectory = "/home/zhaochanglong";

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
  };
}
