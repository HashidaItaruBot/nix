{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.notify = {
      enable = true;
      settings = {
        background_colour = "#000000";
        fps = 60;
        level = "info";
        minimum_width = 50;
        render = "compact";
        stages = "fade_in_slide_out";
        timeout = 3000;
        top_down = true;
      };
    };

    # Use notify as the default notification handler
    opts = {
      termguicolors = true;
    };

    extraConfigLua = ''
      vim.notify = require("notify")
    '';
  };
}