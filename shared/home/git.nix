{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "zhaochanglong";
      user.email = "changlong.zhao@outlook.com";
      user.signingkey = "changlong.zhao@outlook.com";
      pull.rebase = true;
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      commit.gpgsign = true;
    };
  };
}