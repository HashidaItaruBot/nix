_: {
  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Mocha";
    font = {
      name = "Hack Nerd Font";
      size = 16;
    };
    settings = {
      macos_show_window_title_in = "none";
      background_opacity = "0.95";
      cursor_trail = 1;
    };
    keybindings = {
      # Vim-style scroll
      "ctrl+u" = "scroll_page_up";
      "ctrl+d" = "scroll_page_down";
      "ctrl+b" = "scroll_page_up";
      "ctrl+f" = "scroll_page_down";
    };
  };
}
