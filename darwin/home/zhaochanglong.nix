{ self, ... }:
{
  imports = [
    "${self}/shared/home"
    ./git.nix
  ];

  home.homeDirectory = "/Users/zhaochanglong";
}