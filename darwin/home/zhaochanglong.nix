{ self, ... }:
{
  imports = [
    "${self}/shared/home"
  ];

  home.homeDirectory = "/Users/zhaochanglong";
}