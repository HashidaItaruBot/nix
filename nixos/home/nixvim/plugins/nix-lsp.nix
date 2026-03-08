{pkgs, ...}:
{
  programs.nixvim = {
    # 启用LSP支持
    plugins.lsp = {
      enable = true;

      # LSP Keymaps
      keymaps = {
        lspBuf = {
          # 跳转到定义
          gd = "definition";
          # 跳转到类型定义
          gD = "type_definition";
          # 显示悬停信息
          K = "hover";
          # 跳转到实现
          gi = "implementation";
          # 跳转到引用
          gr = "references";
          # 重命名符号
          "<leader>rn" = "rename";
          # 代码操作
          "<leader>ca" = "code_action";
          # 格式化
          "<leader>cf" = "format";
        };
        diagnostic = {
          "<leader>d" = "open_float";
          "[d" = "goto_prev";
          "]d" = "goto_next";
          "<leader>q" = "setloclist";
        };
      };

      # 预定义的服务器配置
      servers = {
        # Nix语言服务器 - 使用nil (推荐)
        nil = {
          enable = true;
          settings = {
            formatting = {
              command = [ "nixpkgs-fmt" ];
            };
            nix = {
              flake = {
                autoEvalInputs = true;
                autoArchive = true;
              };
              formatter = {
                command = "nixpkgs-fmt";
              };
            };
          };
        };

        # Lua
        lua_ls = {
          enable = true;
          settings = {
            Lua = {
              runtime.version = "LuaJIT";
              diagnostics.globals = [ "vim" ];
              workspace = {
                checkThirdParty = false;
                library = [
                  "\${3rd}/luv/library"
                  "\${3rd}/busted/library"
                ];
              };
              telemetry.enabled = false;
            };
          };
        };

        # Python
        pyright.enable = true;

        # TypeScript/JavaScript
        ts_ls.enable = true;

        # JSON
        jsonls.enable = true;

        # YAML
        yamlls.enable = true;

        # HTML
        html.enable = true;

        # CSS
        cssls.enable = true;

        # Rust
        rust_analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;
        };

        # Go
        gopls.enable = true;

        # Bash
        bash-ls.enable = true;

        # Docker
        dockerls.enable = true;

        # Markdown
        marksman.enable = true;
      };
    };

    # LSP 格式化
    plugins.lsp-format.enable = true;

    # LSP Lines (显示诊断行)
    plugins.lsp-lines.enable = true;

    # nvim-navic (面包屑导航)
    plugins.navic = {
      enable = true;
      settings = {
        lsp = {
          auto_attach = true;
        };
      };
    };

    # SchemaStore (JSON Schema)
    plugins.schemastore.enable = true;

    # none-ls (格式化和诊断)
    plugins.none-ls = {
      enable = true;
      sources = {
        formatting = {
          nixpkgs-fmt.enable = true;
          stylua.enable = true;
          prettier = {
            enable = true;
            disableTsServerFormatter = true;
          };
          shfmt.enable = true;
        };
        diagnostics = {
          shellcheck.enable = true;
        };
      };
    };

    # 补全
    plugins.cmp-nvim-lsp.enable = true;

    # 自动补全
    plugins.cmp = {
      enable = true;
      settings = {
        snippet.expand = ''
          function(args)
            require('luasnip').lsp_expand(args.body)
          end
        '';
        mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = "cmp.mapping.select_next_item()";
          "<S-Tab>" = "cmp.mapping.select_prev_item()";
          "<C-n>" = "cmp.mapping.select_next_item()";
          "<C-p>" = "cmp.mapping.select_prev_item()";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-e>" = "cmp.mapping.abort()";
        };
        sources = [
          { name = "nvim_lsp"; }
          { name = "luasnip"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
      };
    };

    # LuaSnip
    plugins.luasnip = {
      enable = true;
      settings = {
        enable_autosnippets = true;
      };
    };

    # Friendly snippets
    plugins.friendly-snippets.enable = true;

    # LSP Kind icons
    plugins.lspkind = {
      enable = true;
      settings.mode = "symbol";
    };
  };
}