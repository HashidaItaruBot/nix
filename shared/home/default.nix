{ pkgs, inputs, ... }:
{
  imports = [
    ./nixvim.nix
  ];

  # 这里的用户名和目录要对应
  home.username = "zhaochanglong";

  # 必须设置，通常设置为当前 NixOS 或 nix-darwin 的版本
  home.stateVersion = "24.05"; 

  programs.git = {
    enable = true;
    settings = {
      user.name = "zhaochanglong";
      user.email = "changlong.zhao@outlook.com";
      pull.rebase = true;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -l";
    };
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "docker"
      ];
    };
  };

  
}
