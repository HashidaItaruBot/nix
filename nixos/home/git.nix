{ lib
, pkgs
, ...
}:
let
  signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5M2RGhIG1CslAdzx+1xcOFiAgJhw0FKFqhe/Wkm1qZ";
  allowedSigners = builtins.toFile "allowed_signers" ''
    changlong.zhao@outlook.com ${signingKey}
  '';
in
{
  programs.git = {
    signing.signer = "${pkgs.openssh}/bin/ssh-keygen";
    settings.gpg.ssh.allowedSignersFile = toString allowedSigners;
  };
}
