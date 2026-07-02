{pkgs, ...}: {
  programs.nixvim = {
    plugins.noice = {
      enable = true;
      settings = {
        lsp = {
          override = {
            "vim.lsp.util.convert_input_to_markdown_lines" = true;
            "vim.lsp.util.stylize_markdown" = true;
            "cmp.entry.get_documentation" = true;
          };
        };
        presets = {
          bottom_search = true;
          command_palette = true;
          long_message_to_split = true;
          inc_rename = false;
          lsp_doc_border = false;
        };
        routes = [
          # Skip show
          {
            filter = {
              event = "msg_show";
              kind = "";
              find = "written";
            };
            opts.skip = true;
          }
          # Skip search count
          {
            filter = {
              event = "msg_show";
              find = "E37";
            };
            opts.skip = true;
          }
        ];
      };
    };
  };
}
