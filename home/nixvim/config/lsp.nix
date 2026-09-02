{
  plugins.lsp = {
    enable = true;

    inlayHints = true;

    keymaps = {
      silent = true;

      diagnostic = {
        "[d" = "goto_prev";
        "]d" = "goto_next";
        "<leader>ld" = "open_float";
        "<leader>lq" = "setloclist";
      };

      lspBuf = {
        K = "hover";
        gd = "definition";
        gD = "declaration";
        gi = "implementation";
        gt = "type_definition";
        gr = "references";
        "<leader>lr" = "rename";
        "<leader>la" = "code_action";
        "<leader>lf" = "format";
      };
    };

    servers = {
      # Nix — system already has nixd / nil / alejandra
      nixd = {
        enable = true;
        settings.formatting.command = ["alejandra"];
      };

      # Rust — use project toolchain (direnv / rustup), don't pull cargo/rustc via nixvim
      rust_analyzer = {
        enable = true;
        installCargo = false;
        installRustc = false;
        packageFallback = true;
      };

      # Python
      basedpyright.enable = true;
      ruff.enable = true;

      # C / C++
      clangd.enable = true;

      # TypeScript / JavaScript
      ts_ls.enable = true;

      # Config / docs / shell
      lua_ls.enable = true;
      bashls.enable = true;
      jsonls.enable = true;
      yamlls.enable = true;
      taplo.enable = true;
      marksman.enable = true;
      html.enable = true;
      cssls.enable = true;
    };
  };
}
