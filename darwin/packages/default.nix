{ pkgs, ... }:
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
    ./homebrew.nix
    home-manager.darwinModules.home-manager homeManagerArgs
  ];
}

