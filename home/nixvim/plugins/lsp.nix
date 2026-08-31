{
  plugins.fidget.enable = true;

  plugins.lazydev = {
    enable = true;
    settings.library = [
      {
        path = "\${3rd}/luv/library";
        words = ["vim%.uv"];
      }
    ];
  };

  plugins.lsp = {
    enable = true;

    servers = {
      # Nix：nil 做 LSP，格式化走 conform + alejandra
      nil_ls.enable = true;
      lua_ls = {
        enable = true;
        settings.completion.callSnippet = "Replace";
      };
      # 按需打开：
      # pyright.enable = true;
      # rust_analyzer.enable = true;
      # gopls.enable = true;
      # ts_ls.enable = true;
    };

    keymaps = {
      diagnostic."<leader>q" = {
        mode = "n";
        action = "setloclist";
        desc = "Open diagnostic [Q]uickfix list";
      };

      lspBuf = {
        "grn" = {
          action = "rename";
          desc = "LSP: [R]e[n]ame";
        };
        "gra" = {
          mode = ["n" "x"];
          action = "code_action";
          desc = "LSP: Code [A]ction";
        };
        "grD" = {
          action = "declaration";
          desc = "LSP: [G]oto [D]eclaration";
        };
      };

      extra = [
        {
          mode = "n";
          key = "grd";
          action.__raw = "require('telescope.builtin').lsp_definitions";
          options.desc = "LSP: [G]oto [D]efinition";
        }
        {
          mode = "n";
          key = "grr";
          action.__raw = "require('telescope.builtin').lsp_references";
          options.desc = "LSP: [G]oto [R]eferences";
        }
        {
          mode = "n";
          key = "gri";
          action.__raw = "require('telescope.builtin').lsp_implementations";
          options.desc = "LSP: [G]oto [I]mplementation";
        }
        {
          mode = "n";
          key = "grt";
          action.__raw = "require('telescope.builtin').lsp_type_definitions";
          options.desc = "LSP: [G]oto [T]ype Definition";
        }
        {
          mode = "n";
          key = "gO";
          action.__raw = "require('telescope.builtin').lsp_document_symbols";
          options.desc = "LSP: Document Symbols";
        }
        {
          mode = "n";
          key = "gW";
          action.__raw = "require('telescope.builtin').lsp_dynamic_workspace_symbols";
          options.desc = "LSP: Workspace Symbols";
        }
      ];
    };
  };
}
