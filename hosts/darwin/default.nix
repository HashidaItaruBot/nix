{ pkgs, ... }: {
  nixpkgs.hostPlatform = "aarch64-darwin";
  
  users.users.zhaochanglong = {
    name = "zhaochanglong";
    home = "/Users/zhaochanglong";
  };
  
  home-manager.users.zhaochanglong = {
    home.homeDirectory = "/Users/zhaochanglong";
  };

  system.stateVersion = 5;
}
