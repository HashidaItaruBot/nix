{ pkgs, ... }: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  environment.systemPackages = with pkgs; [
    hyprlauncher
    hyprlock
    waybar
    rofi
    wl-clipboard
    cliphist
    swayosd
  ];
}
