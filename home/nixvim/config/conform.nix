{
  plugins.conform-nvim = {
    enable = true;

    autoInstall.enable = true;

    settings = {
      notify_on_error = true;
      notify_no_formatters = false;

      format_on_save = {
        lsp_format = "fallback";
        timeout_ms = 500;
      };

      formatters_by_ft = {
        nix = ["alejandra"];
        python = ["ruff_format"];
        c = ["clang_format"];
        cpp = ["clang_format"];
        lua = ["stylua"];
        sh = ["shfmt"];
        bash = ["shfmt"];
        toml = ["taplo"];

        # Rust / TS / JS / JSON / YAML / Markdown / HTML / CSS rely on LSP
        # (rust-analyzer uses the project toolchain via direnv / rustup).
      };
    };
  };
}
