{ self, ... }:
{
  imports = [
    "${self}/shared/home"
    ./git.nix
    ./ssh.nix
    ./openclaw
  ];

  home.homeDirectory = "/Users/zhaochanglong";
}
