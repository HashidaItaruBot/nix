{pkgs, ...}: {
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;
      highlight.enable = true;
      indent.enable = true;
      folding.enable = false;
      nixvimInjections = true;
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        # Web
        html
        css
        javascript
        typescript
        tsx
        vue
        svelte
        json
        jsonnet

        # Programming
        python
        rust
        go
        lua
        java
        kotlin
        c
        cpp
        zig

        # Nix
        nix

        # Config
        toml
        yaml
        markdown
        markdown-inline

        # Shell
        bash
        fish

        # Vim
        vim
        vimdoc
        regex

        # Data
        sql
        xml

        # Other
        make
        dockerfile
        gitignore
        gitcommit
        git_rebase
        diff
        query
      ];
    };

    # Treesitter context (sticky header)
    treesitter-context = {
      enable = true;
      settings = {
        enable = true;
        max_lines = 3;
        min_window_height = 20;
      };
    };

    # Treesitter textobjects
    treesitter-textobjects = {
      enable = true;
      settings = {
        select = {
          enable = true;
          lookahead = true;
          keymaps = {
            "aa" = "@parameter.outer";
            "ia" = "@parameter.inner";
            "af" = "@function.outer";
            "if" = "@function.inner";
            "ac" = "@class.outer";
            "ic" = "@class.inner";
          };
        };
        move = {
          enable = true;
          set_jumps = true;
          goto_next_start = {
            "]m" = "@function.outer";
            "]]" = "@class.outer";
          };
          goto_next_end = {
            "]M" = "@function.outer";
            "][" = "@class.outer";
          };
          goto_previous_start = {
            "[m" = "@function.outer";
            "[[" = "@class.outer";
          };
          goto_previous_end = {
            "[M" = "@function.outer";
            "[]" = "@class.outer";
          };
        };
        swap = {
          enable = true;
          swap_next = {
            "<leader>a" = "@parameter.inner";
          };
          swap_previous = {
            "<leader>A" = "@parameter.inner";
          };
        };
      };
    };
  };
}
