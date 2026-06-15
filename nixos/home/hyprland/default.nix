{
  pkgs,
  config,
  lib,
  ...
}:
let
  modifier = "SUPER";
  terminal = "ghostty";
  browser = "firefox";
  fileManager = "dolphin";
  menu = "rofi -show drun -show-icons";
in
{
  imports = [
    ./waybar.nix
    ./hyprlock.nix
  ];

  home.packages = with pkgs; [
    # 状态栏
    waybar
    # 锁屏
    hyprlock
    # 启动器
    rofi
    # 通知守护进程
    dunst
    libnotify
    # 壁纸
    swww
    # 截图
    grim
    slurp
    swappy
    # 剪贴板
    wl-clipboard
    cliphist
    # 注销菜单
    wlogout
    # 配色选择器
    hyprpicker
    # 亮度控制
    brightnessctl
    # Qt/GTK 主题配置
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    nwg-look
    # polkit 认证代理
    lxqt.lxqt-policykit
    # 音量控制
    wireplumber
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;

    settings = {
      # ===== 环境变量 =====
      env = [
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_QPA_PLATFORMTHEME,qt5ct"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "GDK_BACKEND,wayland,x11"
        "SDL_VIDEODRIVER,wayland"
        "CLUTTER_BACKEND,wayland"
        # fcitx5 输入法
        "GTK_IM_MODULE,fcitx"
        "QT_IM_MODULE,fcitx"
        "XMODIFIERS,@im=fcitx"
        "SDL_IM_MODULE,fcitx"
        "GLFW_IM_MODULE,ibus"
        # 光标
        "XCURSOR_SIZE,24"
        "XCURSOR_THEME,breeze_cursors"
      ];

      # ===== 显示器 =====
      # 请根据实际情况修改显示器名称和分辨率
      # 运行 hyprctl monitors 查看显示器名称
      monitor = [
        ",preferred,auto,1"
      ];

      # ===== 通用设置 =====
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgb(cba6f7)";
        "col.inactive_border" = "rgb(45475a)";
        layout = "dwindle";
        allow_tearing = false;
        resize_on_border = true;
        cursor_inactive_timeout = 5;
      };

      # ===== 装饰 =====
      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 0.9;
        fullscreen_opacity = 1.0;

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };

        blur = {
          enabled = true;
          size = 5;
          passes = 2;
          new_optimizations = true;
          ignore_opacity = true;
          xray = false;
        };

        dim_inactive = false;
        dim_strength = 0.1;
      };

      # ===== 动画 =====
      animations = {
        enabled = true;

        bezier = [
          "overshot, 0.05, 0.9, 0.1, 1.05"
          "smoothOut, 0.36, 0, 0.66, -0.56"
          "smoothIn, 0.25, 1, 0.5, 1"
        ];

        animation = [
          "windows, 1, 5, overshot, popin"
          "windowsOut, 1, 4, smoothOut, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default, slide"
        ];
      };

      # ===== 输入 =====
      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_options = "";

        follow_mouse = 1;
        sensitivity = 0;
        accel_profile = "flat";

        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
          drag_lock = true;
          disable_while_typing = true;
        };
      };

      # ===== 手势 =====
      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
        workspace_swipe_distance = 300;
        workspace_swipe_use_r = true;
      };

      # ===== 杂项 =====
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = false;
        force_default_wallpaper = 0;
        vfr = true;
        vrr = 0;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
        enable_swallow = true;
        swallow_regex = "^(ghostty|kitty|alacritty)$";
      };

      # ===== 窗口规则 =====
      windowrulev2 = [
        # 浮动窗口
        "float, class:^(org.kde.dolphin)$, title:^(Copying|Moving|Properties)"
        "float, class:^(pavucontrol)$"
        "float, class:^(org.kde.polkit-kde-authentication-agent-1)$"
        "float, class:^(nm-connection-editor)$"
        "float, class:^(blueman-manager)$"
        "float, class:^(qt5ct|qt6ct)$"
        "float, class:^(nwg-look)$"
        "float, class:^(org.kde.ark)$"
        "float, title:^(Picture-in-Picture)$"
        # 居中浮动窗口
        "center, class:^(pavucontrol)$"
        "center, class:^(nm-connection-editor)$"
        "center, class:^(blueman-manager)$"
        "center, class:^(qt5ct|qt6ct)$"
        # 钉在顶层
        "pin, title:^(Picture-in-Picture)$"
        # 固定大小
        "size 800 600, class:^(pavucontrol)$"
        "size 860 640, class:^(nm-connection-editor)$"
        # 不聚焦
        "nofocus, class:^$, title:^$"
        # 透明度
        "opacity 0.9, class:^(kitty)$"
      ];

      # ===== 快捷键 =====
      bind = [
        # 终端
        "${modifier}, Return, exec, ${terminal}"
        # 启动器
        "${modifier}, D, exec, ${menu}"
        # 文件管理器
        "${modifier}, E, exec, ${fileManager}"
        # 浏览器
        "${modifier}, B, exec, ${browser}"
        # 关闭窗口
        "${modifier}, Q, killactive"
        # 浮动切换
        "${modifier} SHIFT, Space, togglefloating"
        # 全屏切换
        "${modifier}, F, fullscreen, 1"
        # 伪全屏（保留状态栏）
        "${modifier} SHIFT, F, fullscreen, 0"

        # 窗口焦点
        "${modifier}, left, movefocus, l"
        "${modifier}, right, movefocus, r"
        "${modifier}, up, movefocus, u"
        "${modifier}, down, movefocus, d"

        # 窗口移动
        "${modifier} SHIFT, left, movewindow, l"
        "${modifier} SHIFT, right, movewindow, r"
        "${modifier} SHIFT, up, movewindow, u"
        "${modifier} SHIFT, down, movewindow, d"

        # 窗口大小调整
        "${modifier} CTRL, left, resizeactive, -50 0"
        "${modifier} CTRL, right, resizeactive, 50 0"
        "${modifier} CTRL, up, resizeactive, 0 -50"
        "${modifier} CTRL, down, resizeactive, 0 50"

        # 工作区切换
        "${modifier}, 1, workspace, 1"
        "${modifier}, 2, workspace, 2"
        "${modifier}, 3, workspace, 3"
        "${modifier}, 4, workspace, 4"
        "${modifier}, 5, workspace, 5"
        "${modifier}, 6, workspace, 6"
        "${modifier}, 7, workspace, 7"
        "${modifier}, 8, workspace, 8"
        "${modifier}, 9, workspace, 9"
        "${modifier}, 0, workspace, 10"

        # 窗口移到工作区
        "${modifier} SHIFT, 1, movetoworkspacesilent, 1"
        "${modifier} SHIFT, 2, movetoworkspacesilent, 2"
        "${modifier} SHIFT, 3, movetoworkspacesilent, 3"
        "${modifier} SHIFT, 4, movetoworkspacesilent, 4"
        "${modifier} SHIFT, 5, movetoworkspacesilent, 5"
        "${modifier} SHIFT, 6, movetoworkspacesilent, 6"
        "${modifier} SHIFT, 7, movetoworkspacesilent, 7"
        "${modifier} SHIFT, 8, movetoworkspacesilent, 8"
        "${modifier} SHIFT, 9, movetoworkspacesilent, 9"
        "${modifier} SHIFT, 0, movetoworkspacesilent, 10"

        # 工作区滚动
        "${modifier}, mouse_down, workspace, e+1"
        "${modifier}, mouse_up, workspace, e-1"

        # 特殊工作区（scratchpad）
        "${modifier}, S, togglespecialworkspace, magic"
        "${modifier} SHIFT, S, movetoworkspacesilent, special:magic"

        # 平铺模式切换
        "${modifier}, J, togglesplit"

        # 截图
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "${modifier} SHIFT, S, exec, grim -g \"$(slurp)\" - | swappy -f -"

        # 锁屏
        "${modifier}, L, exec, hyprlock"

        # 注销菜单
        "${modifier} SHIFT, E, exec, wlogout"

        # 剪贴板历史
        "${modifier}, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"

        # 颜色选择器
        "${modifier} SHIFT, C, exec, hyprpicker -a"

        # 媒体键
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      # 鼠标绑定
      bindm = [
        "${modifier}, mouse:272, movewindow"
        "${modifier}, mouse:273, resizewindow"
      ];

      # ===== 自动启动 =====
      exec-once = [
        # 壁纸守护进程
        "swww-daemon"
        # 状态栏
        "waybar"
        # 通知守护进程
        "dunst"
        # 输入法
        "fcitx5 -d"
        # polkit 认证代理
        "lxqt-policykit-agent"
        # 1Password
        "1password --silent"
        # 剪贴板历史
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];
    };
  };

  # 设置 Hyprland 为 SDDM 会话
  xdg.desktopEntries.hyprland = {
    name = "Hyprland";
    exec = "Hyprland";
    type = "Application";
  };
}
