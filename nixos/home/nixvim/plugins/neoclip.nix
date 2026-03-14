{pkgs, ...}: {
  programs.nixvim = {
    plugins.neoclip.enable = true;
  };
}
