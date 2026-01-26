{ pkgs, ... }:
{
  programs.git.signing.signer = "${pkgs._1password-gui}/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
}