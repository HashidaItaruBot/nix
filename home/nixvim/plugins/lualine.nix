{pkgs, ...}: {
  programs.nixvim = {
    plugins.lualine = {
      enable = true;
      settings = {
        options = {
          globalstatus = true;
          icons_enabled = true;
          theme = "catppuccin";
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
          lualine_b = ["branch"];
          lualine_c = [
            {
              __unkeyed-1 = "filename";
              path = 1; # relative path
            }
          ];
          lualine_x = [
            "diagnostics"
            "filetype"
          ];
          lualine_y = ["progress"];
          lualine_z = ["location"];
        };
      };
    };
  };
}
