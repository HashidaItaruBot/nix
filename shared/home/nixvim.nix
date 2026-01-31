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
      settings = {
	integrations = {
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

    clipboard.providers.wl-copy.enable = true;

    opts = {
      number = true;
      shiftwidth = 2;
    };
  };
}
