{pkgs, ...}: {
  programs.nixvim = {
    plugins.trouble = {
      enable = true;
      settings = {
        auto_close = false;
        auto_open = false;
        auto_preview = true;
        auto_refresh = true;
        auto_jump = true;
        focus = false;
        follow = true;
        indent_lines = true;
        max_height = 15;
        mode = "document_diagnostics";
        multiline = true;
        padding = true;
        pinned = false;
        preview = {
          type = "main";
          scratch = true;
        };
        refresh = true;
        signs = {
          error = " ";
          warning = " ";
          hint = " ";
          information = " ";
          other = " ";
        };
        throttle = 100;
        win = {
          type = "float";
          wo = {
            winblend = 0;
          };
        };
      };
    };

    # Trouble keymaps
    keymaps = [
      {
        mode = "n";
        key = "<leader>xx";
        action = "<cmd>Trouble diagnostics toggle<cr>";
        options.desc = "Document Diagnostics";
      }
      {
        mode = "n";
        key = "<leader>xX";
        action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>";
        options.desc = "Buffer Diagnostics";
      }
      {
        mode = "n";
        key = "<leader>cs";
        action = "<cmd>Trouble symbols toggle focus=false<cr>";
        options.desc = "Symbols (Trouble)";
      }
      {
        mode = "n";
        key = "<leader>cl";
        action = "<cmd>Trouble lsp toggle focus=false win.position=right<cr>";
        options.desc = "LSP Definitions / references / ... (Trouble)";
      }
      {
        mode = "n";
        key = "<leader>xL";
        action = "<cmd>Trouble loclist toggle<cr>";
        options.desc = "Location List (Trouble)";
      }
      {
        mode = "n";
        key = "<leader>xQ";
        action = "<cmd>Trouble qflist toggle<cr>";
        options.desc = "Quickfix List (Trouble)";
      }
    ];
  };
}
