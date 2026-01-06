{ self, home-manager, inputs, ... }:
{
  imports = [
    "${self}/shared/home"
  ];

  home.homeDirectory = "/Users/zhaochanglong";
}