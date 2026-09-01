{
  plugins.fidget.enable = true;

  autoGroups.kickstart-lsp-attach.clear = true;

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
      nil_ls.enable = true;
      lua_ls = {
        enable = true;
        settings.completion.callSnippet = "Replace";
      };
    };

    keymaps = {
      diagnostic."<leader>q" = {
        mode = "n";
        action = "setloclist";
        desc = "Open diagnostic [Q]uickfix list";
      };

      extra = [
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
          key = "grd";
          action.__raw = "require('telescope.builtin').lsp_definitions";
          options.desc = "LSP: [G]oto [D]efinition";
        }
        {
          mode = "n";
          key = "gO";
          action.__raw = "require('telescope.builtin').lsp_document_symbols";
          options.desc = "LSP: Open Document Symbols";
        }
        {
          mode = "n";
          key = "gW";
          action.__raw = "require('telescope.builtin').lsp_dynamic_workspace_symbols";
          options.desc = "LSP: Open Workspace Symbols";
        }
        {
          mode = "n";
          key = "grt";
          action.__raw = "require('telescope.builtin').lsp_type_definitions";
          options.desc = "LSP: [G]oto [T]ype Definition";
        }
      ];

      lspBuf = {
        "grn" = {
          action = "rename";
          desc = "LSP: [R]e[n]ame";
        };
        "gra" = {
          mode = ["n" "x"];
          action = "code_action";
          desc = "LSP: [G]oto Code [A]ction";
        };
        "grD" = {
          action = "declaration";
          desc = "LSP: [G]oto [D]eclaration";
        };
      };
    };

    onAttach = ''
      local map = function(keys, func, desc)
        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
      end

      ---@param client vim.lsp.Client
      ---@param method vim.lsp.protocol.Method
      ---@param bufnr? integer
      ---@return boolean
      local function client_supports_method(client, method, bufnr)
        if vim.fn.has 'nvim-0.11' == 1 then
          return client:supports_method(method, bufnr)
        else
          return client.supports_method(method, { bufnr = bufnr })
        end
      end

      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          end,
        })
      end

      if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
        map('<leader>th', function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
        end, '[T]oggle Inlay [H]ints')
      end
    '';
  };
}
