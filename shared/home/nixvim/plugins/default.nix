{pkgs, ...}:
{
  imports = [
    ./avante.nix
    ./lazygit.nix
    ./treesitter.nix
    ./gitsigns.nix
    ./neo-tree.nix
    ./neoclip.nix
    ./telescope.nix
  ];
}
