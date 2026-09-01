{
  imports = [
    ./kickstart/gitsigns.nix
    ./kickstart/which-key.nix
    ./kickstart/telescope.nix
    ./kickstart/lsp.nix
    ./kickstart/conform.nix
    ./kickstart/blink-cmp.nix
    ./kickstart/todo-comments.nix
    ./kickstart/mini.nix
    ./kickstart/treesitter.nix

    # 取消注释以启用 kickstart 可选插件：
    # ./kickstart/debug.nix
    # ./kickstart/indent-blankline.nix
    # ./kickstart/lint.nix
    # ./kickstart/autopairs.nix
    # ./kickstart/neo-tree.nix

    # 自定义插件放 plugins/custom/ 并在此导入
  ];
}
