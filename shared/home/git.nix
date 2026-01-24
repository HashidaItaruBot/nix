{ pkgs, ... }:
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
    };
    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5M2RGhIG1CslAdzx+1xcOFiAgJhw0FKFqhe/Wkm1qZ"; # 你的 1Password 公钥
      format = "ssh";
      signByDefault = true;
      signer = "${pkgs._1password-gui}/bin/op-ssh-sign"; 
    };
  };
}