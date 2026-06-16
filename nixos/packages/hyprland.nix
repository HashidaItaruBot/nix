{ pkgs, ... }: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  # Hyprland 锁屏：PAM 权限（hyprlock 配置在 home-manager）
  programs.hyprlock.enable = true;

  # Hyprland 生态工具包
  environment.systemPackages = with pkgs; [
    pyprland
    hyprpicker
    hyprcursor
    hyprpaper
    hyprsunset
    hyprpolkitagent
  ];
}
