{
  globals = {
    mapleader = " ";
    maplocalleader = " ";
  };

  opts = {
    # Always reserve the sign column so gitsigns / diagnostics
    # don't shift text when signs appear.
    signcolumn = "yes";

    # Always show line numbers on the left.
    number = true;
    # Keep the number column tight; default 4 leaves a wide gap next to signs.
    numberwidth = 3;
  };
}
