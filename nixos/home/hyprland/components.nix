{ pkgs, ... }:
{
  # ---- Hyprland 配套组件 ----

  # 锁屏：替代 Plasma kscreenlocker（在 Hyprland 会话下不生效）
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 0; # 立即锁屏，无宽限期
        no_fade_in = false;
        no_fade_out = false;
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
          outer_color = "rgb(24, 24, 37)";
          outline_thickness = 5;
          placeholder_text = ''<span foreground="##cad3f5">Password...</span>'';
          shadow_passes = 2;
        }
      ];
    };
  };

  # 空闲管理：配合 hyprlock
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "loginctl lock-session";
        before_sleep_cmd = "loginctl lock-session";
        lock_cmd = "pidof hyprlock || hyprlock";
        ignore_dbus_inhibit = false;
      };
      listener = [
        {
          timeout = 300; # 5 分钟
          on-timeout = "loginctl lock-session"; # 锁屏（触发 hyprlock）
        }
        {
          timeout = 330; # 5.5 分钟
          on-timeout = "hyprctl dispatch dpms off"; # 关屏
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 600; # 10 分钟
          on-timeout = "systemctl suspend"; # 挂起
        }
      ];
    };
  };

  # 状态栏
  programs.waybar = {
    enable = true;
    # 使用默认 style.css，模块配置在 settings 中
    settings = [
      {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "tray"
          "network"
          "bluetooth"
          "pulseaudio"
          "battery"
          "custom/power"
        ];

        "hyprland/workspaces" = {
          format = "{icon}";
          on-click = "activate";
        };

        "hyprland/window" = {
          max-length = 50;
        };

        clock = {
          format = " {:%Y-%m-%d %H:%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        tray = {
          spacing = 10;
        };

        network = {
          format-wifi = " {essid} ({signalStrength}%)";
          format-ethernet = " Wired";
          format-disconnected = " Disconnected";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
        };

        bluetooth = {
          format = " {status}";
          format-connected = " {device_alias}";
          tooltip-format = "{controller}: {status}";
          on-click = "blueman-manager";
        };

        pulseaudio = {
          format = " {volume}% {icon}";
          format-muted = " Muted";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = " {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-full = " Full";
        };

        "custom/power" = {
          format = " ";
          on-click = "wlogout --protocol layer-shell";
          tooltip = false;
        };
      }
    ];

    style = ''
      * {
        font-family: "Sarasa Mono SC", "Symbols Nerd Font";
        font-size: 14px;
      }

      window#waybar {
        background-color: rgba(30, 30, 46, 0.9);
        color: #cdd6f4;
        border-bottom: 1px solid rgba(137, 180, 250, 0.3);
      }

      .modules-right, .modules-center, .modules-left {
        margin: 0 8px;
      }

      #workspaces button {
        padding: 0 8px;
        color: #cdd6f4;
        background: transparent;
        border-radius: 4px;
      }

      #workspaces button.active {
        background-color: rgba(137, 180, 250, 0.3);
      }

      #workspaces button:hover {
        background-color: rgba(205, 214, 244, 0.2);
      }

      #clock, #network, #bluetooth, #pulseaudio, #battery, #tray, #custom-power {
        padding: 0 10px;
        margin: 0 4px;
        color: #cdd6f4;
      }

      #clock {
        font-weight: bold;
      }

      #battery.warning {
        color: #fab387;
      }

      #battery.critical {
        color: #f38ba8;
      }
    '';
  };

  # 通知
  services.mako = {
    enable = true;
    settings = {
      defaultTimeout = 5000;
      anchor = "top-right";
      backgroundColor = "#1e1e2e";
      textColor = "#cdd6f4";
      borderColor = "#89b4fa";
      borderRadius = 8;
      borderSize = 2;
      padding = "12";
      margin = "20";
      font = "Sarasa Mono SC 14";
    };
  };
}
