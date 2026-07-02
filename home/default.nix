{
  self,
  inputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
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
