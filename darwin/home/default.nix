{ self, home-manager, inputs, ... }:
{
  imports = [
    home-manager.darwinModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.zhaochanglong = import "${self}/shared/home";
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.backupFileExtension = "bak";
    }
  ];
}