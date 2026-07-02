{
  lib,
  pkgs,
  ...
}: let
  signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5M2RGhIG1CslAdzx+1xcOFiAgJhw0FKFqhe/Wkm1qZ";
  allowedSigners = builtins.toFile "allowed_signers" ''
    changlong.zhao@outlook.com ${signingKey}
  '';
in {
  programs.git = {
    enable = true;
    settings = {
      user.name = "zhaochanglong";
      user.email = "changlong.zhao@outlook.com";
      pull.rebase = true;
      gpg.ssh.allowedSignersFile = toString allowedSigners;
    };
    signing = {
      key = signingKey;
      format = "ssh";
      signByDefault = true;
      signer = "${pkgs._1password-gui}/bin/op-ssh-sign";
    };
  };
}
