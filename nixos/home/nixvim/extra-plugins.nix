{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      blink-cmp-avante
    ];
  };
}
