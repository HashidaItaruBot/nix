_: {
  imports = [
    ./new-api.nix
    ./openlist.nix
  ];

  services.podman.enable = true;
}
