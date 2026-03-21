# NixOS Containers Module
# Exports all container configurations

{ ... }:
{
  virtualisation.containers.enable = true;

  imports = [
    ./openhands.nix
  ];
}
