{
  config,
  pkgs,
  lib,
  ...
}:
{
  wayland.windowManager.hyprland = {
    enable = true;
    # 使用 NixOS 模块提供的 Hyprland 包，避免版本冲突
    package = null;
    portalPackage = null;
    configType = "hyprlang";
  };

  # 安装配套 CLI 工具（UWSM 启动的图形应用由各自模块负责）
  home.packages = with pkgs; [
    fuzzel # 启动器
    grim # 截图
    slurp # 区域选择
    wl-clipboard # 剪贴板
    wf-recorder # 屏幕录制
    playerctl # 媒体控制
    brightnessctl # 亮度控制（笔记本）
    wlogout # 电源菜单
  ];

  imports = [
    ./settings.nix
    ./bindings.nix
    ./rules.nix
    ./exec.nix
    ./env.nix
    ./components.nix
  ];
}
