{
  inputs,
  ...
}:
{
  imports = [
    inputs.sops-nix.darwinModules.sops
  ];

  sops.age.sshKeyPaths = [ "/var/root/.ssh/id_ed25519" ];
}
