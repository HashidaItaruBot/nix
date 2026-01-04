{ pkgs, inputs, ... }:
{
  imports = [
    # nixvim 模块
    inputs.nixvim.homeModules.nixvim
    ./nixvim.nix
  ];
  # 这里的用户名和目录要对应
  home.username = "zhaochanglong";
  # Remove hardcoded homeDirectory to allow platform overrides or use lib.mkDefault
  # home.homeDirectory = "/Users/zhaochanglong";

  # 必须设置，通常设置为当前 NixOS 或 nix-darwin 的版本
  home.stateVersion = "24.05"; 

  # Packages have been moved to ../packages/common.nix

  programs.git = {
    enable = true;
    settings = {
      user.name = "zhaochanglong";
      user.email = "changlong.zhao@outlook.com";
    };
    settings = {
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
