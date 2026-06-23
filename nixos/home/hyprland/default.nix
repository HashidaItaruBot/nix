{
  config,
  pkgs,
  lib,
  ...
}:
let
  mainMod = "SUPER";
  terminal = "ghostty";
  fileManager = "dolphin";
  browser = "firefox";
  menu = "wofi --show drun";

  workspaceKey = i: if i == 10 then "0" else toString i;
  workspaceBinds =
    (map (i: "${mainMod}, ${workspaceKey i}, workspace, ${toString i}") (lib.range 1 10))
    ++ (map (i: "${mainMod} SHIFT, ${workspaceKey i}, movetoworkspace, ${toString i}") (
      lib.range 1 10
    ));
in
{
  home.packages = with pkgs; [
    wofi
    waybar
    wl-clipboard
    playerctl
    brightnessctl
    pamixer
    grim
    slurp
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = true;

    settings = {
      monitor = [ ",preferred,auto,auto" ];

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      exec-once = [
        "waybar"
        "linux-wallpaperengine"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 0.9;
        shadow.enabled = true;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.17;
        };
      };

      animations.enabled = true;
      bezier = [
        "easeOutQuint, 0.23, 1, 0.32, 1"
        "easeInOutCubic, 0.65, 0.05, 0.36, 1"
        "quick, 0.15, 0, 0.1, 1"
      ];
      animation = [
        "global, 1, 10, default"
        "windows, 1, 5, easeOutQuint, popin 80%"
        "windowsOut, 1, 5, default, popin 80%"
        "fade, 1, 5, default"
        "workspaces, 1, 4, easeInOutCubic, fade"
      ];

      dwindle.preserve_split = true;
      master.new_status = "master";

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = false;
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad.natural_scroll = false;
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
      };

      windowrulev2 = [
        "nomaximizerequest, class:.*"
        "float, class:^(org.kde.polkit-kde-authentication-agent-1)$"

        # 浮动工具窗口
        "float, class:^(pavucontrol)$"
        "float, class:^(org.pulseaudio.pavucontrol)$"
        "float, class:^(wofi)$"
        "float, class:^(org.keepassxc.KeePassXC)$"
        "float, class:^(Bitwarden)$"
        "float, class:^(1password)$"
        "float, class:^(OnePassword)$"
        "size 800 600, class:^(pavucontrol)$"
        "size 900 600, class:^(org.keepassxc.KeePassXC)$"

        # 文件对话框 - 浮动居中
        "float, class:^(xdg-desktop-portal-gtk)$"
        "center, class:^(xdg-desktop-portal-gtk)$"

        # Steam
        "float, class:^(Steam)$"
        "float, title:^(Steam Settings)$"
        "size 1200 800, class:^(Steam)$, title:^(Steam)$"

        # Discord / Vesktop
        "workspace 4 silent, class:^(discord)$"
        "workspace 4 silent, class:^(Vesktop)$"

        # JetBrains IDE
        "float, class:^(jetbrains-.*)$, title:^(Welcome to .*)$"
        "float, class:^(jetbrains-.*)$, title:^(win.*)$"

        # JetBrains 内嵌工具窗口
        "float, title:^(Password.*)$"
        "float, title:^(Open Project.*)$"

        # 浏览器 - 独立 workspace
        "workspace 2 silent, class:^(firefox)$"
        "workspace 2 silent, class:^(firefoxdeveloperedition)$"
        "workspace 2 silent, class:^(chromium)$"
        "workspace 2 silent, class:^(google-chrome)$"

        # 透明度 - 非焦点窗口
        "opacity 0.95 0.85, class:.*"
      ];

      bind =
        [
          "${mainMod}, Q, exec, ${terminal}"
          "${mainMod}, C, killactive"
          "${mainMod} SHIFT, M, exit,"
          "${mainMod}, E, exec, ${fileManager}"
          "${mainMod}, B, exec, ${browser}"
          "${mainMod}, V, togglefloating"
          "${mainMod}, R, exec, ${menu}"
          "${mainMod}, P, pseudo"
          "${mainMod}, J, togglesplit"
          "${mainMod}, L, exec, hyprlock"

          "${mainMod}, left, movefocus, l"
          "${mainMod}, right, movefocus, r"
          "${mainMod}, up, movefocus, u"
          "${mainMod}, down, movefocus, d"

          "${mainMod}, S, togglespecialworkspace, magic"
          "${mainMod} SHIFT, S, movetoworkspace, special:magic"

          "${mainMod}, mouse_down, workspace, e+1"
          "${mainMod}, mouse_up, workspace, e-1"

          ", Print, exec, grim - | wl-copy"
          "${mainMod}, Print, exec, grim -g \"$(slurp)\" - | wl-copy"
          "${mainMod} SHIFT, Print, exec, grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"
        ]
        ++ workspaceBinds;

      bindm = [
        "${mainMod}, mouse:272, movewindow"
        "${mainMod}, mouse:273, resizewindow"
      ];

      binde = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];
    };
  };

  # 空闲锁屏
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  # 锁屏界面
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 5;
        no_fade_in = false;
      };
      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];
      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_centering = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = "Password...";
          shadow_passes = 2;
        }
      ];
    };
  };

  # 壁纸：复用 services.linux-wallpaperengine（见 zhaochanglong.nix），
  # 供 Plasma 与 Hyprland 会话共用。Hyprland 通过上面 exec-once 拉起。
  # 该服务默认 WantedBy = graphical-session.target，对 Hyprland 同样生效。


  # 状态栏
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "hyprland/workspaces" ];
        modules-right = [ "pulseaudio" "network" "cpu" "memory" "battery" "clock" "tray" ];
        "hyprland/workspaces" = {
          format = "{name}";
          on-click = "activate";
        };
        "hyprland/window" = {
          format = "{}";
          max-length = 50;
        };
        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "M";
          format-icons = { default = ["V" "V"]; };
          on-click = "pavucontrol";
        };
        network = {
          format-wifi = "W {essid}";
          format-ethernet = "E {ipaddr}";
          format-disconnected = "X";
        };
        cpu = { format = "C {usage}%"; };
        memory = { format = "M {percentage}%"; };
        battery = {
          format = "{icon} {capacity}%";
          format-icons = ["B" "B" "B" "B" "B"];
        };
        clock = {
          format = "{:%Y-%m-%d %H:%M}";
          tooltip-format = "{:%A %B %d}";
        };
        tray = { spacing = 8; };
      };
    };
    style = ''
      * { font-family: monospace; font-size: 13px; }
      window#waybar { background-color: rgba(30, 30, 46, 0.9); color: #cdd6f4; }
      .modules-right { margin: 0 8px; }
      #workspaces button { padding: 0 8px; color: #cdd6f4; }
      #workspaces button.active { background-color: #89b4fa; color: #1e1e2e; }
    '';
  };
}
