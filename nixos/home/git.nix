{ pkgs, ... }:
{
  programs.git.signing.signer = "${pkgs._1password-gui}/bin/op-ssh-sign";
}