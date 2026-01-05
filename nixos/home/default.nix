{ self, inputs, ... }:
{
  imports = [
    "${self}/shared/home"
    inputs.plasma-manager.homeModules.plasma-manager
  ];


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