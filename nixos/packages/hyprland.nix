{ pkgs, ... }: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  environment.systemPackages = with pkgs; [
    hyprlauncher
    hyprlock
    hypridle
    waybar
    rofi
    wl-clipboard
    cliphist
    swayosd
  ];
}
