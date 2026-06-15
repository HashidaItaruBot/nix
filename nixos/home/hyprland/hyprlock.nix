{
  pkgs,
  config,
  lib,
  ...
}:
{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        disable_loading_bar = true;
        grace = 0;
        hide_cursor = true;
        no_fade_in = false;
        no_fade_out = false;
        ignore_empty_input = true;
      };

      background = {
        monitor = "";
        path = "screenshot";
        blur_passes = 3;
        blur_size = 8;
        color = "rgba(30, 30, 46, 0.8)";
      };

      # 日期
      label = [
        {
          monitor = "";
          text = ''cmd[update:1000] echo "$(date +'%Y年%m月%d日')"'';
          color = "rgba(203, 166, 247, 1)";
          font_size = 20;
          font_family = "Hack Nerd Font";
          position = "0, -200";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = ''cmd[update:1000] echo "$(date +'%H:%M:%S')"'';
          color = "rgba(245, 194, 231, 1)";
          font_size = 80;
          font_family = "Hack Nerd Font";
          position = "0, -140";
          halign = "center";
          valign = "center";
        }
      ];

      # 用户头像（如果有的话）
      image = {
        monitor = "";
        path = "${config.home.homeDirectory}/.face";
        size = 100;
        rounding = -1;
        border_size = 2;
        border_color = "rgb(203, 166, 247)";
        rotate = 0;
        reload_time = -1;
        position = "0, 60";
        halign = "center";
        valign = "center";
      };

      # 输入框
      input-field = {
        monitor = "";
        size = "300, 50";
        outline_thickness = 2;
        dots_size = 0.2;
        dots_spacing = 0.2;
        dots_center = true;
        outer_color = "rgb(203, 166, 247)";
        inner_color = "rgb(30, 30, 46)";
        font_color = "rgb(205, 214, 244)";
        fade_on_empty = false;
        placeholder_text = ''<span foreground="##6c7086">输入密码...</span>'';
        hide_input = false;
        rounding = 10;
        position = "0, -20";
        halign = "center";
        valign = "center";
      };
    };
  };
}
