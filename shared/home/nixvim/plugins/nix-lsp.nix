{pkgs, ...}:
{
  programs.nixvim = {
    # 启用LSP支持
    plugins.lsp = {
      enable = true;

      # 预定义的服务器配置
      servers = {
        # Nix语言服务器 - 使用nil (推荐)
        nil = {
          enable = true;
          # nil配置
          settings = {
            formatting = {
              command = [ "nixpkgs-fmt" ];
            };
            nix = {
              # 启用flake支持
              flake = {
                autoEvalInputs = true;
                autoArchive = true;
              };
              # 格式化器设置
              formatter = {
                command = "nixpkgs-fmt";
              };
            };
          };
        };

        # 也可以使用nixd作为替代
        # nixd = {
        #   enable = true;
        #   settings = {
        #     formatting = {
        #       command = [ "nixpkgs-fmt" ];
        #     };
        #   };
        # };
      };

      # 启用LSP功能
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
          "<leader>f" = "format";
        };
      };
    };

    # 启用LSP相关的插件
    plugins.lsp-format.enable = true;
    plugins.lsp-lines.enable = true;

    # 启用none-ls用于格式化（备用）
    plugins.none-ls = {
      enable = true;
      sources.formatting.nixpkgs-fmt.enable = true;
    };

    # 启用cmp-nvim-lsp用于自动补全
    plugins.cmp-nvim-lsp.enable = true;

    # 启用自动补全
    plugins.cmp = {
      enable = true;
      settings.mapping = {
        "<C-Space>" = "cmp.mapping.complete()";
        "<CR>" = "cmp.mapping.confirm({ select = true })";
        "<Tab>" = "cmp.mapping.select_next_item()";
        "<S-Tab>" = "cmp.mapping.select_prev_item()";
      };
      settings.sources = [
        { name = "nvim_lsp"; }
        { name = "path"; }
        { name = "buffer"; }
      ];
    };
  };
}
