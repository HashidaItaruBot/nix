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
    have_nerd_font = true; # Ghostty: Hack Nerd Font
  };

  # Plasma/X11 为主，同时保留 Wayland（Hyprland）剪贴板
  clipboard = {
    register = "unnamedplus";
    providers = {
      xsel.enable = true;
      wl-copy.enable = true;
    };
  };

  opts = {
    number = true;
    relativenumber = true;
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

  autoGroups.nixvim-highlight-yank.clear = true;

  autoCmd = [
    {
      event = ["TextYankPost"];
      desc = "Highlight when yanking text";
      group = "nixvim-highlight-yank";
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
  };

  plugins = {
    web-devicons.enable = true;
    guess-indent.enable = true;
  };
}
