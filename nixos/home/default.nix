{ self, ... }:
{
  imports = [
    "${self}/shared/home"
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
}