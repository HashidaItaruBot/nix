{ pkgs, ... }:
let
  # 使用 hyprpolkitagent（Hyprland 生态原生），避免与 Plasma6 的 polkit-kde-agent 冲突
  polkitAgent = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
in
{
  wayland.windowManager.hyprland.settings = {
    # ---- 自启项（UWSM 感知）----
    # 系统级 withUWSM = true，用 `uwsm app --` 让 systemd 接管生命周期
    exec-once = [
      # 状态栏与通知
      "uwsm app -- waybar"
      "uwsm app -- mako"

      # 空闲管理（hyprlock 由 SUPER+L 或 hypridle 触发）
      "uwsm app -- hypridle"

      # 权限代理（Hyprland 原生 polkit agent）
      "uwsm app -- ${polkitAgent}"

      # 蓝牙托盘（系统服务已启用 blueman）
      "uwsm app -- blueman-applet"

      # 输入法（系统级 fcitx5 已启用，此处冗余拉起确保会话内激活）
      "uwsm app -- fcitx5 -d --replace"

      # 壁纸：linux-wallpaperengine 已配置为 systemd 用户服务（见 zhaochanglong.nix），
      # 此处不再冗余启动，避免双重进程
    ];
  };
}
