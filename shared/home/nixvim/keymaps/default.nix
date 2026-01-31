{pkgs, ...}:
{
  imports = [
    ./neo-tree.nix
    ./telescope.nix
    ./general.nix
    ./lsp.nix
  ];
}
