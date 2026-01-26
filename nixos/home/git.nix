{ pkgs, lib, ... }:
{
  programs.git.signing.signer = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
}

