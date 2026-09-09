{
  plugins.nvim-autopairs = {
    enable = true;

    settings = {
      check_ts = true;
      disable_filetype = [
        "TelescopePrompt"
        "neo-tree"
        "vim"
        "AgenticInput"
      ];
    };
  };
}
