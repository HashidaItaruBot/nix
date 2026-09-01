{
  colorschemes.tokyonight = {
    enable = true;
    settings = {
      style = "night";
      styles.comments.italic = false;
    };
  };

  globals = {
    mapleader = " ";
    maplocalleader = " ";
    have_nerd_font = true;
  };

  clipboard = {
    register = "unnamedplus";
    providers = {
      xsel.enable = true;
      wl-copy.enable = true;
    };
  };

  opts = {
    number = true;
    # relativenumber = true;
    mouse = "a";
    showmode = false;
    breakindent = true;
    undofile = true;
    ignorecase = true;
    smartcase = true;
    signcolumn = "yes";
    updatetime = 250;
    timeoutlen = 300;
    splitright = true;
    splitbelow = true;
    list = true;
    listchars.__raw = "{ tab = '» ', trail = '·', nbsp = '␣' }";
    inccommand = "split";
    cursorline = true;
    scrolloff = 10;
    confirm = true;
    hlsearch = true;
  };

  autoGroups.kickstart-highlight-yank.clear = true;

  autoCmd = [
    {
      event = ["TextYankPost"];
      desc = "Highlight when yanking (copying) text";
      group = "kickstart-highlight-yank";
      callback.__raw = ''
        function()
          vim.hl.on_yank()
        end
      '';
    }
  ];

  diagnostic.settings = {
    severity_sort = true;
    float = {
      border = "rounded";
      source = "if_many";
    };
    underline.severity.__raw = ''vim.diagnostic.severity.ERROR'';
    signs.__raw = ''
      vim.g.have_nerd_font and {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚 ',
          [vim.diagnostic.severity.WARN] = '󰀪 ',
          [vim.diagnostic.severity.INFO] = '󰋽 ',
          [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
      } or {}
    '';
    virtual_text = {
      source = "if_many";
      spacing = 2;
      format.__raw = ''
        function(diagnostic)
          local diagnostic_message = {
            [vim.diagnostic.severity.ERROR] = diagnostic.message,
            [vim.diagnostic.severity.WARN] = diagnostic.message,
            [vim.diagnostic.severity.INFO] = diagnostic.message,
            [vim.diagnostic.severity.HINT] = diagnostic.message,
          }
          return diagnostic_message[diagnostic.severity]
        end
      '';
    };
  };

  plugins = {
    web-devicons.enable = true;
    guess-indent.enable = true;
  };
}
