{ self, pkgs, home-manager, ... }:
let 
  homeManagerArgs = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.zhaochanglong = import ./home;
    home-manager.extraSpecialArgs = { inherit inputs; };
    home-manager.backupFileExtension = "bak";
  };
in
{
  imports = [
    "${self}/shared/system"
    home-manager.darwinModules.home-manager homeManagerArgs
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
