{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      # LSP 服务器
      lua-language-server
      pyright
      nil

      stylua
      ripgrep
      fd
      git
      tree-sitter
      gcc
    ];
  };

  # 将本地的 nvim 文件夹递归映射到 ~/.config/nvim
  xdg.configFile."nvim" = {
    source = ./.;
    recursive = true;
  };
}
