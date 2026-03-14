{
  inputs,
  self,
  ...
}: {
  imports = [
    inputs.home-manager.darwinModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.zhaochanglong = import ./zhaochanglong.nix;
      home-manager.extraSpecialArgs = {inherit inputs self;};
      home-manager.backupFileExtension = "bak";
    }
  ];
}
