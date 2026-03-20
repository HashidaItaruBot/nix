{self, ...}: {
  imports = [
    "${self}/shared/home"
    ./git.nix
    ./ssh.nix
    ./colima.nix
  ];

  home.homeDirectory = "/Users/zhaochanglong";
}
