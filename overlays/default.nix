# NixOS module: attach reusable overlays to nixpkgs.
{inputs, ...}: {
  nixpkgs.overlays = [
    (import ./unstable.nix inputs)
  ];
}
