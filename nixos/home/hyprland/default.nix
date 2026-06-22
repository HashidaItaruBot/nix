{
  config,
  pkgs,
  lib,
  ...
}:
let
  mainMod = "SUPER";
  terminal = "ghotty";
  fileManager = "dolphin";
  menu = "hyprlauncher";

  # 工作区 1-10 的按键绑定 (i=10 映射到按键 0)
  workspaceKey = i: if i == 10 then "0" else toString i;
  workspaceBinds =
    (map (i: "${mainMod}, ${workspaceKey i}, workspace, ${toString i}") (lib.range 1 10))
    ++ (map (i: "${mainMod} SHIFT, ${workspaceKey i}, movetoworkspace, ${toString i}") (
      lib.range 1 10
    ));
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    # 使用 NixOS 模块提供的 Hyprland 包，避免版本冲突
    package = null;
    portalPackage = null;
    configType = "hyprlang";

    settings = {
      # ---- 显示器 ----
      monitor = [ ",preferred,auto,auto" ];

      # ---- 环境变量 ----
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      # ---- 通用设置 ----
      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        resize_on_border = false;
        allow_tearing = false;
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

      # 动画配置 (spring 动画使用内置 spring 预设替代自定义 spring)
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
        force_default_wallpaper = -1;
        disable_hyprland_logo = false;
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

      # ---- 窗口规则 ----
      windowrulev2 = [
        "nomaximizerequest, class:.*" # 阻止窗口最大化请求
        "nofocus, xwayland:1, class:^$, title:^$" # 修复 XWayland 拖拽问题
        "move 20 monitor_h-120, float, class:hyprland-run" # hyprland-run 窗口定位
      ];

      # ---- 按键绑定 ----
      bind = [
        "${mainMod}, Q, exec, ${terminal}"
        "${mainMod}, C, killactive"
        "${mainMod}, M, exec, command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"
        "${mainMod}, E, exec, ${fileManager}"
        "${mainMod}, V, togglefloating"
        "${mainMod}, R, exec, ${menu}"
        "${mainMod}, P, pseudo"
        "${mainMod}, J, togglesplit"

        # 方向键移动焦点
        "${mainMod}, left, movefocus, l"
        "${mainMod}, right, movefocus, r"
        "${mainMod}, up, movefocus, u"
        "${mainMod}, down, movefocus, d"

        # 特殊工作区 (scratchpad)
        "${mainMod}, S, togglespecialworkspace, magic"
        "${mainMod} SHIFT, S, movetoworkspace, special:magic"

        # 滚轮切换工作区
        "${mainMod}, mouse_down, workspace, e+1"
        "${mainMod}, mouse_up, workspace, e-1"
      ]
      ++ workspaceBinds;

      # 鼠标绑定
      bindm = [
        "${mainMod}, mouse:272, movewindow"
        "${mainMod}, mouse:273, resizewindow"
      ];

      # 多媒体按键 (带重复)
      binde = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];

      # 媒体控制按键 (锁定)
      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];
    };
  };
}
