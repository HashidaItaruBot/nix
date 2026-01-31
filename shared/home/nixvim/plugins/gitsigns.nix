{pkgs, ...}:
{
  programs.nixvim = {
    plugins.gitsigns.enable = true;
  };
}
