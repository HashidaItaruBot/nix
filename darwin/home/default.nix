{
  inputs,
  self,
  ...
}: {
  imports = [
    inputs.home-manager.darwinModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.zhaochanglong = import ./zhaochanglong.nix;
        extraSpecialArgs = {inherit inputs self;};
        backupFileExtension = "bak";
      };
    }
  ];
}
