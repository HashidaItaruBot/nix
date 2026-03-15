{
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.sops-nix.darwinModules.sops
  ];

  # Only configure SSH key paths if the key exists (not in CI)
  sops.age.sshKeyPaths = [ "/var/root/.ssh/id_ed25519" ];
}
