{ pkgs, ... }:
{
  imports = [
    ./packages
  ];

  users.users.zhaochanglong = {
    shell = pkgs.zsh;
  };
}