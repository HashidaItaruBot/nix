{ ... }:
{
  programs.kitty = {
    enable = true;
    theme = "Catppuccin-Mocha";
    font = {
      name = "Hack Nerd Font";
      size = 16;
    };
    settings = {
      start_as_maximized = "yes";
      macos_show_window_title_in = "none";
      # 配合 Catppuccin 颜值更高
      background_opacity = "0.95";
      hide_window_decorations = "titlebar-only"; # 隐藏 macOS 标题栏
    };
  };
}