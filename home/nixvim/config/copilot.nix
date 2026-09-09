{
  # Official GitHub Copilot plugin (github/copilot.vim).
  # After switch: open nvim and run `:Copilot setup` to authenticate.
  plugins.copilot-vim.enable = true;

  # Disable Copilot's built-in <Tab> so blink.cmp can own the key first.
  # blink falls through to this mapping when no completion item is selected
  # (see completion.nix).
  globals.copilot_no_tab_map = true;

  keymaps = [
    {
      mode = "i";
      key = "<Tab>";
      action = ''copilot#Accept("\<Tab>")'';
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
