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

  programs.ghostty = {
    settings = {
      theme = "catppuccin-macchiato"; # Ghostty 内置了大量主题
      font-size = 12;
      font-family = "JetBrainsMono Nerd Font";
      
      # 性能与外观平衡
      window-decoration = true;
      confirm-close-surface = false;
      
      # 跨平台特别设置
      macos-option-as-alt = true; # 让 macOS 的 Option 键表现得像 Linux 的 Alt
    };
  };
}
