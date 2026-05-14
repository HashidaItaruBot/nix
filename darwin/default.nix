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
  # Docker CLI tools are installed via shared system packages
  # Docker Desktop is installed via Homebrew (see packages/default.nix)
  # After installation, Docker Desktop will automatically configure permissions
}
