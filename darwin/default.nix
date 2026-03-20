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

  # Docker configuration for macOS
  # Docker CLI tools are installed via shared system packages
  # Docker Desktop is installed via Homebrew (see packages/default.nix)
  # After installation, Docker Desktop will automatically configure permissions

  # Podman machine auto-start via launchd agent
  launchd.user.agents.podman-start = {
    command = "${./scripts/init-podman-machine.sh}";
    serviceConfig = {
      KeepAlive = false;  # 只启动一次，不持续重启
      RunAtLoad = true;   # 登录时运行
      StandardOutPath = "/tmp/podman-start.log";
      StandardErrorPath = "/tmp/podman-start.err";
    };
  };
}
