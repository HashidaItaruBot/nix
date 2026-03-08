{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.mini = {
      enable = true;
      modules = {
        pairs = { };
        surround = { };
        ai = { };
        comment = { };
        icons = { };
        diff = {
          view = {
            style = "sign";
          };
        };
      };
    };
  };
}