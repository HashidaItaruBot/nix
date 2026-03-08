{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.bufferline = {
      enable = true;
      settings = {
        options = {
          diagnostics = "nvim_lsp";
          diagnostics_indicator = ''
            function(count, level, diagnostics_dict, context)
              local s = " "
              for e, n in pairs(diagnostics_dict) do
                local sym = e == "error" and " "
                  or (e == "warning" and " " or "" )
                s = s .. n .. sym
              end
              return s
            end
          '';
          offsets = [
            {
              filetype = "neo-tree";
              text = "Neo-tree";
              highlight = "Directory";
              text_align = "left";
            }
          ];
          separator_style = "thin";
          show_buffer_close_icons = true;
          show_close_icon = false;
        };
      };
    };

    # Bufferline keymaps
    keymaps = [
      {
        mode = "n";
        key = "<S-h>";
        action = "<cmd>BufferLineCyclePrev<cr>";
        options.desc = "Prev Buffer";
      }
      {
        mode = "n";
        key = "<S-l>";
        action = "<cmd>BufferLineCycleNext<cr>";
        options.desc = "Next Buffer";
      }
      {
        mode = "n";
        key = "[b";
        action = "<cmd>BufferLineCyclePrev<cr>";
        options.desc = "Prev Buffer";
      }
      {
        mode = "n";
        key = "]b";
        action = "<cmd>BufferLineCycleNext<cr>";
        options.desc = "Next Buffer";
      }
      {
        mode = "n";
        key = "<leader>bd";
        action = "<cmd>bdelete<cr>";
        options.desc = "Delete Buffer";
      }
      {
        mode = "n";
        key = "<leader>bb";
        action = "<cmd>BufferLinePick<cr>";
        options.desc = "Pick Buffer";
      }
    ];
  };
}