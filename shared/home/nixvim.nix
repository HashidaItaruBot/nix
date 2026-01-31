{ inputs, pkgs, ... }:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
    globals.mapleader = " ";

    colorschemes.catppuccin = {
      enable = true;
      settings.integrations = {
        aerial = true;
        alpha = true;
        cmp = true;
        dashboard = true;
        flash = true;
        fzf = true;
        grug_far = true;
        gitsigns = true;
        headlines = true;
        illuminate = true;
        indent_blankline.enabled = true;
        leap = true;
        lsp_trouble = true;
        mason = true;
        mini = true;
        navic = {
          enabled = true;
          custom_bg = "lualine";
        };
        neotest = true;
        neotree = true;
        noice = true;
        notify = true;
        snacks = true;
        telescope = true;
        treesitter_context = true;
        which_key = true;
      };
    };

    plugins.avante = {
      enable = true;
      settings = {
        provider = "deepseek";
        auto_suggestions_provider = "deepseek";
        providers = {
          deepseek = {
            __inherited_from = "openai";
            api_key_name = "DEEPSEEK_API_KEY";
            endpoint = "https://api.deepseek.com";
            model = "deepseek-coder";
          };
        };
        behaviour = {
          auto_set_keymaps = true;
        };
      };
    };
    plugins.lazygit.enable = true;
    plugins.treesitter = {
      enable = true;
      highlight.enable = true;
      indent.enable = true;
      folding.enable = false;
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        bash
        json
        lua
        make
        markdown
        nix
        regex
        toml
        vim
        vimdoc
        xml
        yaml
      ];
    };
    plugins.gitsigns.enable = true;
    plugins.neo-tree = {
      enable = true;
    };
    keymaps = [
      # NeoTree Root Dir
      {
	mode = "n";
	key = "<leader>fe";
	action = ''<cmd>lua require("neo-tree.command").execute({ toggle = true, dir = vim.fn.getcwd() })<cr>'';
	options.desc = "Explorer NeoTree (Root Dir)";
      }
      # NeoTree CWD
      {
	mode = "n";
	key = "<leader>fE";
	action = ''<cmd>lua require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })<cr>'';
	options.desc = "Explorer NeoTree (cwd)";
      }
      # 别名映射 (remap = true)
      {
	mode = "n";
	key = "<leader>e";
	action = "<leader>fe";
	options = { 
	  desc = "Explorer NeoTree (Root Dir)";
	  remap = true; 
	};
      }
      {
	mode = "n";
	key = "<leader>E";
	action = "<leader>fE";
	options = { 
	  desc = "Explorer NeoTree (cwd)";
	  remap = true; 
	};
      }
      # Git Explorer
      {
	mode = "n";
	key = "<leader>ge";
	action = ''<cmd>lua require("neo-tree.command").execute({ source = "git_status", toggle = true })<cr>'';
	options.desc = "Git Explorer";
      }
      # Buffer Explorer
      {
	mode = "n";
	key = "<leader>be";
	action = ''<cmd>lua require("neo-tree.command").execute({ source = "buffers", toggle = true })<cr>'';
	options.desc = "Buffer Explorer";
      }
    ];

    plugins.neoclip.enable = true;
    plugins.telescope = {
      enable = true;
      extensions = {
	      file-browser.enable = true;
	      zoxide.enable = true;
      };

      keymaps = {
        # 快捷跳转
        "<leader>," = {
          action = "buffers sort_mru=true sort_lastused=true";
          options.desc = "Switch Buffer";
        };
        "<leader>/" = {
          action = "live_grep";
          options.desc = "Grep (Root Dir)";
        };
        "<leader>:" = {
          action = "command_history";
          options.desc = "Command History";
        };
        "<leader><space>" = {
	  action = "find_files";
	  options.desc = "Find Files (Root Dir)";
	};

        # f - Find 模块
        "<leader>fb" = {
          action = "buffers sort_mru=true sort_lastused=true ignore_current_buffer=true";
          options.desc = "Buffers";
        };
        "<leader>fB" = {
	  action = "buffers";
	  options.desc = "Buffers (all)";
	};
        "<leader>ff" = {
	  action = "find_files";
	  options.desc = "Find Files (Root Dir)";
	};
        "<leader>fg" = {
	  action = "git_files";
	  options.desc = "Find Files (git-files)";
	};
        "<leader>fr" = {
	  action = "oldfiles";
	  options.desc = "Recent";
	};

        # g - Git 模块
        "<leader>gc" = {
	  action = "git_commits";
	  options.desc = "Commits";
	};
        "<leader>gs" = {
	  action = "git_status";
	  options.desc = "Status";
	};
        "<leader>gS" = {
	  action = "git_stash";
	  options.desc = "Git Stash";
	};

        # s - Search 模块
        "<leader>s\"" = "registers";
        "<leader>s/" = "search_history";
        "<leader>sa" = "autocommands";
        "<leader>sb" = "current_buffer_fuzzy_find";
        "<leader>sc" = "command_history";
        "<leader>sC" = "commands";
        "<leader>sd" = "diagnostics";
        "<leader>sg" = "live_grep";
        "<leader>sh" = "help_tags";
        "<leader>sH" = "highlights";
        "<leader>sj" = "jumplist";
        "<leader>sk" = "keymaps";
        "<leader>sl" = "loclist";
        "<leader>sM" = "man_pages";
        "<leader>sm" = "marks";
        "<leader>so" = "vim_options";
        "<leader>sR" = "resume";
        "<leader>sq" = "quickfix";
        "<leader>sw" = {
          action = "grep_string";
          options.desc = "Word (Root Dir)";
        };
        "<leader>ss" = {
          action = "lsp_document_symbols";
          options.desc = "Goto Symbol";
        };
        "<leader>sS" = {
          action = "lsp_dynamic_workspace_symbols";
          options.desc = "Goto Symbol (Workspace)";
        };

        # UI 模块
        "<leader>uC" = {
          action = "colorscheme enable_preview=true";
          options.desc = "Colorscheme with Preview";
        };
      };
    };

    clipboard.providers.wl-copy.enable = true;

    opts = {
      number = true;
      shiftwidth = 2;
    };
  };
}
