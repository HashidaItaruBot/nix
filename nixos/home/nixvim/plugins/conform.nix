{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = {
          nix = [ "nixpkgs_fmt" ];
          lua = [ "stylua" ];
          python = [ "black" ];
          javascript = [ "prettier" ];
          typescript = [ "prettier" ];
          javascriptreact = [ "prettier" ];
          typescriptreact = [ "prettier" ];
          json = [ "prettier" ];
          yaml = [ "prettier" ];
          markdown = [ "prettier" ];
          html = [ "prettier" ];
          css = [ "prettier" ];
          sh = [ "shfmt" ];
          bash = [ "shfmt" ];
          rust = [ "rustfmt" ];
          go = [ "gofmt" ];
          "_" = [ "trim_whitespace" ];
        };
        format_on_save = {
          timeout_ms = 500;
          lsp_fallback = true;
        };
        default_format_opts = {
          lsp_format = "fallback";
        };
      };
    };

    # Conform keymaps
    keymaps = [
      {
        mode = [ "n" "v" ];
        key = "<leader>cf";
        action.__raw = ''
          function()
            require("conform").format({ async = true, lsp_fallback = true })
          end
        '';
        options.desc = "Format";
      }
    ];

    # Formatters
    extraPackages = with pkgs; [
      nixpkgs-fmt
      stylua
      black
      prettierd
      shfmt
      rustfmt
      go
    ];
  };
}