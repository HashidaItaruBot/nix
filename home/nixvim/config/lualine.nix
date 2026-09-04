{
  plugins.lualine = {
    enable = true;

    settings = {
      options = {
        # catppuccin 2.0 exposes flavour-specific themes (no plain "catppuccin").
        theme = "catppuccin-mocha";
        globalstatus = true;
        icons_enabled = true;
        component_separators = {
          left = "";
          right = "";
        };
        section_separators = {
          left = "";
          right = "";
        };
      };

      sections = {
        lualine_a = ["mode"];
        lualine_b = ["branch" "diff" "diagnostics"];
        lualine_c = ["filename"];
        lualine_x = ["encoding" "fileformat" "filetype"];
        lualine_y = ["progress"];
        lualine_z = ["location"];
      };
    };
  };
}
