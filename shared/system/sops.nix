{ inputs, self, config, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  # sops 配置
  sops.age.sshKeyPaths = [ "/root/.ssh/id_ed25519" ];
}
