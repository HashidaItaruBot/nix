_: {
  wayland.windowManager.hyprland.settings = {
    # ---- 环境变量 ----
    env = [
      # 光标
      "XCURSOR_SIZE,24"
      "HYPRCURSOR_SIZE,24"

      # Qt / GTK
      "QT_QPA_PLATFORM,wayland;xcb"
      "QT_QPA_PLATFORMTHEME,qt6ct"
      "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"

      # XDG
      "XDG_CURRENT_DESKTOP,Hyprland"
      "XDG_SESSION_TYPE,wayland"
      "XDG_SESSION_DESKTOP,Hyprland"

      # SDL / Java
      "SDL_VIDEODRIVER,wayland"
      "_JAVA_AWT_WM_NONREPARENTING,1"

      # AMD 显卡（硬件层已由 hardware-configuration.nix 处理）
      "LIBVA_DRIVER_NAME,radeonsi"
      "VDPAU_DRIVER,radeonsi"

      # 输入法（与 nixos/default.nix 中 mkForce "" 策略保持一致，
      # 不设置 GTK_IM_MODULE / QT_IM_MODULE，让 fcitx5 走 Wayland 输入协议）
      "XMODIFIERS,@im=fcitx"
    ];
  };
}
