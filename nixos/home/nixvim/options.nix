{ pkgs, ... }:
{
  programs.nixvim = {
    opts = {
      # Basic
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      softtabstop = 2;

      # Editing
      smartindent = true;
      autoindent = true;
      breakindent = true;

      # Search
      ignorecase = true;
      smartcase = true;
      incsearch = true;
      hlsearch = false;

      # UI
      termguicolors = true;
      signcolumn = "yes";
      showmode = false;
      scrolloff = 8;
      sidescrolloff = 8;
      wrap = false;
      linebreak = true;
      cursorline = true;
      splitbelow = true;
      splitright = true;
      showtabline = 2;
      cmdheight = 1;
      pumheight = 10;
      completeopt = "menu,menuone,noselect";
      conceallevel = 0;
      foldcolumn = "0";
      foldlevel = 99;
      foldlevelstart = 99;
      foldenable = true;

      # Performance
      updatetime = 200;
      timeout = true;
      timeoutlen = 300;
      redrawtime = 1500;
      ttimeoutlen = 10;

      # Backup & Swap
      backup = false;
      swapfile = false;
      undofile = true;

      # Misc
      mouse = "a";
      mousemoveevent = true;
      report = 1;
      inccommand = "split";
      virtualedit = "block";
      formatoptions = "jcroqlnt";
      grepprg = "rg --vimgrep";
      grepformat = "%f:%l:%c:%m";
    };
  };
}
