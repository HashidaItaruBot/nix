{
  pkgs,
  lib,
  ...
}: {
  extraPlugins = with pkgs.vimPlugins; [
    nvim-metals
  ];

  extraPackages = with pkgs; [
    metals
  ];

  extraConfigLua = ''
    local metals_config = require("metals").bare_config()

    metals_config.settings = {
      showImplicitArguments = true,
      showInferredType = true,

      -- Use the Nix-managed Metals binary; do not download via coursier.
      -- metalsBinaryPath must live under settings (nvim-metals nests it as settings.metals).
      metalsBinaryPath = "${lib.getExe pkgs.metals}",
    }

    -- Use LSP progress notifications instead of Metals status bar extension.
    metals_config.init_options.statusBarProvider = "off"

    local ok, blink = pcall(require, "blink.cmp")
    if ok then
      metals_config.capabilities = blink.get_lsp_capabilities()
    end

    metals_config.on_attach = function(_client, bufnr)
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, {
          buffer = bufnr,
          silent = true,
          desc = desc,
        })
      end

      -- Match global LSP keymaps from lsp.nix
      map("n", "K", vim.lsp.buf.hover, "Hover")
      map("n", "gd", vim.lsp.buf.definition, "Goto definition")
      map("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
      map("n", "gi", vim.lsp.buf.implementation, "Goto implementation")
      map("n", "gt", vim.lsp.buf.type_definition, "Goto type definition")
      map("n", "gr", vim.lsp.buf.references, "References")
      map("n", "<leader>lr", vim.lsp.buf.rename, "Rename")
      map("n", "<leader>la", vim.lsp.buf.code_action, "Code action")
      map("n", "<leader>lf", function()
        vim.lsp.buf.format({ async = true })
      end, "Format")

      map("n", "[d", function()
        vim.diagnostic.goto_prev({ float = true })
      end, "Previous diagnostic")
      map("n", "]d", function()
        vim.diagnostic.goto_next({ float = true })
      end, "Next diagnostic")
      map("n", "<leader>ld", vim.diagnostic.open_float, "Line diagnostics")
      map("n", "<leader>lq", vim.diagnostic.setloclist, "Diagnostics loclist")

      -- Metals-specific
      map("n", "<leader>lw", function()
        require("metals").hover_worksheet()
      end, "Metals worksheet")
      map("n", "<leader>mi", function()
        require("metals").import_build()
      end, "Metals import build")
      map("n", "<leader>mc", function()
        require("telescope").extensions.metals.commands()
      end, "Metals commands")
    end

    pcall(function()
      require("telescope").load_extension("metals")
    end)

    local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "scala", "sbt", "java" },
      callback = function()
        require("metals").initialize_or_attach(metals_config)
      end,
      group = nvim_metals_group,
    })
  '';
}
