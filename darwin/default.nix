{
  self,
  pkgs,
  home-manager,
  ...
}:
{
  imports = [
    "${self}/shared/system"
    ./home
    ./packages
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.enable = false;

  system.primaryUser = "zhaochanglong";
  users.users.zhaochanglong = {
    name = "zhaochanglong";
    home = "/Users/zhaochanglong";
  };

  # macOS System Defaults
  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.ApplePressAndHoldEnabled = false; # allow keyboard press continuesly
  };

  system.stateVersion = 5;

  # TouchID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;
}
