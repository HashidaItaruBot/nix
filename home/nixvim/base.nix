{pkgs, ...}: {
  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };
  };
}
