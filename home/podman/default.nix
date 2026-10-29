_: {
  imports = [
    ./maibot.nix
    ./openlist.nix
  ];

  services.podman.enable = true;
}
