{pkgs, ...}: {
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
    grim
    slurp
    wl-clipboard
    cliphist
    swayosd
  ];
}
