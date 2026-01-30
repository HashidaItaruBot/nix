{ self, ... }:
{
  imports = [
    "${self}/shared/home"
    ./git.nix
    ./ssh.nix
  ];

  home.homeDirectory = "/Users/zhaochanglong";
}
