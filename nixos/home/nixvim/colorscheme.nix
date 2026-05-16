{pkgs, ...}: {
  programs.nixvim = {
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        transparent_background = false;
        show_end_of_buffer = false;
        term_colors = true;
        dim_inactive = {
          enabled = false;
          shade = "dark";
          percentage = 0.15;
        };
        integrations = {
          alpha = true;
          blink_cmp = true;
          bufferline = true;
          cmp = true;
          dashboard = true;
          flash = true;
          fzf = true;
          gitgutter = false;
          gitsigns = true;
          illuminate = true;
          indent_blankline = {
            enabled = true;
            scope_color = "";
            colored_indent_levels = false;
          };
          lsp_trouble = true;
          markdown = true;
          mason = true;
          mini = true;
          native_lsp = {
            enabled = true;
            underlines = {
              errors = ["underline"];
              hints = ["underline"];
              warnings = ["underline"];
              information = ["underline"];
            };
          };
          navic = {
            enabled = true;
            custom_bg = "lualine";
          };
          neotree = true;
          noice = true;
          notify = true;
          nvimtree = false;
          semantic_tokens = true;
          telescope = {
            enabled = true;
            style = "nvchad";
          };
          treesitter = true;
          treesitter_context = true;
          which_key = true;
        };
      };
    };
  };
}
