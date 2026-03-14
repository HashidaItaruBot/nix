{pkgs, ...}: {
  programs.nixvim = {
    plugins.which-key = {
      enable = true;
      settings = {
        delay = 200;
        expand = 1;
        notify = false;
        preset = false;
        replace = {
          desc = [
            ["<space>" "SPACE"]
            ["<leader>" "SPACE"]
            ["<cr>" "RETURN"]
            ["<tab>" "TAB"]
          ];
        };
        spec = [
          {
            __unkeyed-1 = "<leader>b";
            group = "buffer";
          }
          {
            __unkeyed-1 = "<leader>c";
            group = "code";
          }
          {
            __unkeyed-1 = "<leader>d";
            group = "debug";
          }
          {
            __unkeyed-1 = "<leader>f";
            group = "find";
          }
          {
            __unkeyed-1 = "<leader>g";
            group = "git";
          }
          {
            __unkeyed-1 = "<leader>l";
            group = "lsp";
          }
          {
            __unkeyed-1 = "<leader>n";
            group = "neo-tree";
          }
          {
            __unkeyed-1 = "<leader>s";
            group = "search";
          }
          {
            __unkeyed-1 = "<leader>t";
            group = "toggle";
          }
          {
            __unkeyed-1 = "<leader>u";
            group = "ui";
          }
          {
            __unkeyed-1 = "<leader>w";
            group = "window";
          }
          {
            __unkeyed-1 = "<leader>x";
            group = "diagnostics/quickfix";
          }
          {
            __unkeyed-1 = "[";
            group = "prev";
          }
          {
            __unkeyed-1 = "]";
            group = "next";
          }
          {
            __unkeyed-1 = "g";
            group = "goto";
          }
          {
            __unkeyed-1 = "z";
            group = "fold";
          }
        ];
      };
    };
  };
}
