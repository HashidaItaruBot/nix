{
  pkgs,
  config,
  lib,
  ...
}:
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 36;
        spacing = 4;

        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "tray"
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "battery"
          "backlight"
        ];

        # 工作区
        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "一";
            "2" = "二";
            "3" = "三";
            "4" = "四";
            "5" = "五";
            "6" = "六";
            "7" = "七";
            "8" = "八";
            "9" = "九";
            "10" = "十";
            urgent = "";
            default = "";
          };
          on-click = "activate";
          persistent-workspaces = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
            "4" = [ ];
            "5" = [ ];
          };
        };

        # 窗口标题
        "hyprland/window" = {
          format = "{title}";
          max-length = 80;
          separate-outputs = true;
        };

        # 时钟
        clock = {
          format = "{:%Y-%m-%d %H:%M}";
          tooltip-format = "<big>{:%Y年%m月}</big>\n<tt>{calendar}</tt>";
        };

        # 系统托盘
        tray = {
          icon-size = 18;
          spacing = 10;
        };

        # 音量
        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "🔇";
          format-icons = {
            default = [
              "🔈"
              "🔉"
              "🔊"
            ];
          };
          scroll-step = 5;
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };

        # 网络
        network = {
          format-wifi = " {signalStrength}%";
          format-ethernet = "";
          format-disconnected = "⚠";
          tooltip-format = "{ipaddr}/{cidr} via {gwaddr}";
        };

        # CPU
        cpu = {
          format = " {usage}%";
          tooltip = true;
          interval = 2;
        };

        # 内存
        memory = {
          format = " {used:0.1f}G";
          tooltip = true;
          interval = 5;
        };

        # 电池
        battery = {
          format = "{icon} {capacity}%";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
          format-charging = "⚡ {capacity}%";
          states = {
            warning = 30;
            critical = 15;
          };
        };

        # 背光亮度
        backlight = {
          format = "☀ {percent}%";
        };
      };
    };

    style = ''
      * {
        font-family: "Hack Nerd Font", "Noto Sans CJK SC", sans-serif;
        font-size: 13px;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background: rgba(30, 30, 46, 0.85);
        color: #cdd6f4;
      }

      #workspaces {
        margin: 4px;
        padding: 0 4px;
      }

      #workspaces button {
        padding: 0 6px;
        color: #6c7086;
        background: transparent;
      }

      #workspaces button.active {
        color: #cba6f7;
        background: rgba(203, 166, 247, 0.15);
        border-radius: 4px;
      }

      #workspaces button.urgent {
        color: #f38ba8;
      }

      #workspaces button:hover {
        color: #cdd6f4;
        background: rgba(205, 214, 244, 0.1);
        border-radius: 4px;
      }

      #window {
        margin: 4px 8px;
        color: #a6adc8;
      }

      #clock {
        margin: 4px 8px;
        color: #f5c2e7;
        font-weight: bold;
      }

      #tray {
        margin: 4px 4px;
      }

      #pulseaudio {
        margin: 4px 4px;
        color: #89b4fa;
      }

      #network {
        margin: 4px 4px;
        color: #a6e3a1;
      }

      #cpu {
        margin: 4px 4px;
        color: #fab387;
      }

      #memory {
        margin: 4px 4px;
        color: #f9e2af;
      }

      #battery {
        margin: 4px 4px;
        color: #94e2d5;
      }

      #backlight {
        margin: 4px 4px;
        color: #cba6f7;
      }

      label.module {
        margin: 0 2px;
      }

      tooltip {
        background: rgba(30, 30, 46, 0.95);
        border: 1px solid #45475a;
        border-radius: 6px;
        padding: 4px 8px;
      }

      tooltip label {
        color: #cdd6f4;
      }
    '';
  };
}
