{pkgs, ...}: {
  imports = [
    # UI
    ./lualine.nix
    ./bufferline.nix
    ./alpha.nix
    ./noice.nix
    ./notify.nix
    ./which-key.nix
    ./indent-blankline.nix
    ./illuminate.nix
    ./todo-comments.nix

    # Coding
    ./mini.nix
    ./flash.nix
    ./trouble.nix
    ./conform.nix
    ./yanky.nix

    # Git
    ./lazygit.nix
    ./gitsigns.nix

    # LSP & Completion
    ./treesitter.nix
    ./neo-tree.nix
    ./neoclip.nix
    ./telescope.nix
    ./nix-lsp.nix
    ./web-devicons.nix

    # AI
    ./avante.nix
  ];
}
