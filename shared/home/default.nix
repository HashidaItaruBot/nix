{ pkgs, inputs, ... }:
{
  imports = [
    ./nixvim.nix
    ./kitty.nix
    ./ssh.nix
    ./git.nix
  ];

  home.username = "zhaochanglong";

  home.stateVersion = "24.05";

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
