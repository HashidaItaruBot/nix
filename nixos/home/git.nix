{pkgs, ...}: {
  programs.git.signing.signer = "${pkgs.openssh}/bin/ssh-keygen";
}