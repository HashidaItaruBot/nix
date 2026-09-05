{
  # Official GitHub Copilot plugin (github/copilot.vim).
  # After switch: open nvim and run `:Copilot setup` to authenticate.
  plugins.copilot-vim.enable = true;

  # Disable default <Tab> accept; use Alt+l instead.
  globals.copilot_no_tab_map = true;

  keymaps = [
    {
      mode = "i";
      key = "<M-l>";
      action = ''copilot#Accept("")'';
      options = {
        silent = true;
        expr = true;
        script = true;
        # Required so the string returned by copilot#Accept is not
        # re-processed as Neovim keycodes.
        replace_keycodes = false;
        desc = "Accept Copilot suggestion";
      };
    }
  ];
}
