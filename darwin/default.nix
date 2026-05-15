{self, ...}: {
  imports = [
    "${self}/shared/system"
    ./home
    ./packages
    ./sops.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.enable = false;

  system = {
    primaryUser = "zhaochanglong";
    defaults = {
      dock.autohide = true;
      finder.AppleShowAllExtensions = true;
      NSGlobalDomain.ApplePressAndHoldEnabled = false; # allow keyboard press continuesly
    };
    stateVersion = 5;
  };

  users.users.zhaochanglong = {
    name = "zhaochanglong";
    home = "/Users/zhaochanglong";
  };

  # TouchID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };

  # Docker configuration for macOS
  # docker CLI + colima (replaces Docker Desktop) installed via packages/default.nix
  # Start colima: colima start
}
