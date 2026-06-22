_: {
  wayland.windowManager.hyprland.settings = {
    # ---- 显示器 ----
    # 短期保留 auto 配置；运行 `hyprctl monitors` 后替换为具体配置：
    #   monitor=DP-3,2560x1440@144,0x0,1
    monitor = [
      ",preferred,auto,auto"
    ];

    # ---- 通用设置 ----
    general = {
      gaps_in = 5;
      gaps_out = 20;
      border_size = 2;
      "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
      "col.inactive_border" = "rgba(595959aa)";
      resize_on_border = false;
      allow_tearing = false; # AMD 偶有撕裂，按需切换
      layout = "dwindle";
    };

    # ---- 装饰 ----
    decoration = {
      rounding = 10;
      rounding_power = 2;
      active_opacity = 1.0;
      inactive_opacity = 1.0;
      shadow = {
        enabled = true;
        range = 4;
        render_power = 3;
        color = "rgba(1a1a1aee)";
      };
      blur = {
        enabled = true;
        size = 3;
        passes = 1;
        vibrancy = 0.1696;
      };
    };

    # ---- 动画 ----
    animations = {
      enabled = true;
    };

    # 贝塞尔曲线
    bezier = [
      "easeOutQuint, 0.23, 1, 0.32, 1"
      "easeInOutCubic, 0.65, 0.05, 0.36, 1"
      "linear, 0, 0, 1, 1"
      "almostLinear, 0.5, 0.5, 0.75, 1"
      "quick, 0.15, 0, 0.1, 1"
    ];

    # 动画配置
    animation = [
      "global, 1, 10, default"
      "border, 1, 5.39, easeOutQuint"
      "windows, 1, 4.79, easeOutQuint"
      "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
      "windowsOut, 1, 1.49, linear, popin 87%"
      "fadeIn, 1, 1.73, almostLinear"
      "fadeOut, 1, 1.46, almostLinear"
      "fade, 1, 3.03, quick"
      "layers, 1, 3.81, easeOutQuint"
      "layersIn, 1, 4, easeOutQuint, fade"
      "layersOut, 1, 1.5, linear, fade"
      "fadeLayersIn, 1, 1.79, almostLinear"
      "fadeLayersOut, 1, 1.39, almostLinear"
      "workspaces, 1, 1.94, almostLinear, fade"
      "workspacesIn, 1, 1.21, almostLinear, fade"
      "workspacesOut, 1, 1.94, almostLinear, fade"
      "zoomFactor, 1, 7, quick"
    ];

    # ---- 布局 ----
    dwindle = {
      preserve_split = true;
    };

    master = {
      new_status = "master";
    };

    scrolling = {
      fullscreen_on_one_column = true;
    };

    # ---- 杂项 ----
    misc = {
      force_default_wallpaper = -1; # -1 = 随机；wallpaperengine 管壁纸，不依赖此项
      disable_hyprland_logo = true;
    };

    # ---- 输入 ----
    input = {
      kb_layout = "us";
      kb_variant = "";
      kb_model = "";
      kb_options = "";
      kb_rules = "";
      follow_mouse = 1;
      sensitivity = 0;
      touchpad = {
        natural_scroll = false;
      };
    };

    # ---- 触控手势 ----
    gestures = {
      workspace_swipe = true;
      workspace_swipe_fingers = 3;
    };

    # ---- 设备 ----
    device = [
      {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
      }
    ];
  };
}
