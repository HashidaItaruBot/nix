_: {
  imports = [
    ./openlist.nix
    ./openhands.nix
  ];

  services.podman.enable = true;
}
