_: {
  wayland.windowManager.hyprland.settings = {
    # ---- 窗口规则 ----
    windowrulev2 = [
      # Polkit 弹窗浮动居中（hyprpolkitagent）
      "float, class:^(polkit-gnome-authentication-agent-1)$|^(hyprpolkitagent)$|^(org.kde.polkit-kde-authentication-agent-1)$"
      "center, class:^(polkit-gnome-authentication-agent-1)$|^(hyprpolkitagent)$|^(org.kde.polkit-kde-authentication-agent-1)$"

      # 文件选择器浮动
      "float, title:^(Open Files)$"
      "float, title:^(File Upload)$"
      "float, title:^(Save File)$"
      "float, title:^(Open File)$"

      # 常见工具浮动
      "float, class:^(org.pulseaudio.pavucontrol)$"
      "float, class:^(.blueman-manager-wrapped)$"
      "float, class:^(nm-connection-editor)$"

      # 1Password 浮动（可选 pin）
      "float, class:^(1password)$"

      # Steam 浮动子窗口（保留主窗口平铺）
      "float, class:^(steam)$, title:^(?!Steam$)"

      # 浏览器对话框
      "float, class:^(firefox)$, title:^(?!Mozilla Firefox$)"

      # XWayland 拖拽修复（保留原配置）
      "nofocus, xwayland:1, class:^$, title:^$"

      # 阻止最大化请求（保留原配置）
      "nomaximizerequest, class:.*"

      # hyprland-run 定位（保留原配置）
      "move 20 monitor_h-120, class:hyprland-run"
      "float, class:hyprland-run"
    ];

    # ---- 图层规则 ----
    layerrule = [
      "blur, waybar"
      "ignorezero, waybar"
      "blur, launcher"
      "ignorealpha 0.5, launcher"
      "blur, notifications"
      "ignorealpha 0.69, notifications"
    ];
  };
}
