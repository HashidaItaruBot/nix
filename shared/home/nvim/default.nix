{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      lua-language-server
      stylua
      ripgrep
      fd
      git
    ];
  };

  # 将本地的 nvim 文件夹递归映射到 ~/.config/nvim
  xdg.configFile."nvim" = {
    source = ./.;
    recursive = true;
  };
}
