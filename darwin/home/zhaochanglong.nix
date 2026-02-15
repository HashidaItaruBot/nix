{ self, ... }:
{
  imports = [
    "${self}/shared/home"
    ./git.nix
    ./ssh.nix
    ./openclaw.nix
  ];

  home.homeDirectory = "/Users/zhaochanglong";
}
