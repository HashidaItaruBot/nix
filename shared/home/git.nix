{ ... }:
{
  # Git SSH signing allowed signers file
  home.file.".ssh/allowed_signers" = {
    source = ./allowed_signers;
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "zhaochanglong";
      user.email = "changlong.zhao@outlook.com";
      pull.rebase = true;
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      gpg.ssh.defaultKeyCommand = "ssh-add -L";  # 让 Git 从 SSH agent 获取密钥
      commit.gpgsign = true;
    };
  };
}