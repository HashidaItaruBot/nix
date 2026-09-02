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

  # Detect tab/space width from the current file contents.
  plugins.guess-indent = {
    enable = true;
    settings = {
      auto_cmd = true;
      # Prefer project .editorconfig when present.
      override_editorconfig = false;
    };
  };
}
