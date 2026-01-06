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

  system.primaryUser = "zhaochanglong";

  nix.enable = false;
  
  users.users.zhaochanglong = {
    name = "zhaochanglong";
    home = "/Users/zhaochanglong";
  };
  
  home-manager.users.zhaochanglong = {
    home.homeDirectory = "/Users/zhaochanglong";
  };

  system.stateVersion = 5;

  # macOS System Defaults
  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.ApplePressAndHoldEnabled = false; # allow keyboard press continuesly
  };

  # TouchID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;
}
