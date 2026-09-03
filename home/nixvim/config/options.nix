{
  globals = {
    mapleader = " ";
    maplocalleader = " ";
  };

  opts = {
    # Draw gitsigns / diagnostics in the number column to avoid
    # a separate sign gutter and the gap next to line numbers.
    signcolumn = "yes";

    # Always show line numbers on the left.
    number = true;
    relativenumber = true;
    cursorline = true;
    scrolloff = 8;

    # Share yank/paste with the system clipboard (requires +clipboard).
    clipboard = "unnamedplus";

    # Search: case-insensitive unless the pattern contains uppercase.
    ignorecase = true;
    smartcase = true;

    # Allow switching buffers without saving; faster CursorHold for plugins.
    hidden = true;
    updatetime = 250;

    # Baseline indentation; guess-indent / .editorconfig override per buffer.
    autoindent = true;
    smartindent = true;
    expandtab = true;
    shiftwidth = 2;
    tabstop = 2;
    softtabstop = 2;
    smarttab = true;
    breakindent = true;
  };
}
