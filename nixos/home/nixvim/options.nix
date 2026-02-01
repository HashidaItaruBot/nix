{ pkgs, ... }:
{
  programs.nixvim = {
    opts = {
      number = true;
      shiftwidth = 2;
    };
  };
}
