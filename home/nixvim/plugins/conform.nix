{pkgs, ...}: {
  extraPackages = with pkgs; [
    alejandra
    stylua
  ];

  plugins.conform-nvim = {
    enable = true;
    settings = {
      notify_on_error = false;
      format_on_save = ''
        function(bufnr)
          local disable_filetypes = { c = true, cpp = true }
          if disable_filetypes[vim.bo[bufnr].filetype] then
            return nil
          end
          return {
            timeout_ms = 500,
            lsp_format = "fallback",
          }
        end
      '';
      formatters_by_ft = {
        nix = ["alejandra"];
        lua = ["stylua"];
      };
    };
  };

  keymaps = [
    {
      mode = ["n" "v"];
      key = "<leader>f";
      action.__raw = ''
        function()
          require('conform').format { async = true, lsp_format = "fallback" }
        end
      '';
      options.desc = "[F]ormat buffer";
    }
  ];
}
