{pkgs, ...}: {
  programs.nixvim = {
    clipboard = {
      providers.wl-copy.enable = true;
      providers.xclip.enable = true;
    };
  };
}
