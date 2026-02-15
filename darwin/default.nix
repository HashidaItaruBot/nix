{
  self,
  inputs,
  ...
}:
{
  imports = [
    "${self}/shared/system"
    ./home
    ./packages
    ./sops.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  #nixpkgs.overlays = [ inputs.nix-openclaw.overlays.default ];
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

  # Docker configuration for macOS
  # Docker CLI tools are installed via shared system packages
  # Docker Desktop is installed via Homebrew (see packages/default.nix)
  # After installation, Docker Desktop will automatically configure permissions
}
