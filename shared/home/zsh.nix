{
  pkgs,
  inputs,
  ...
}:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -l";
      # nom aliases for better build output
      nb = "nom build";
      ns = "nom build . && sudo nixos-rebuild switch --flake .";
      nd = "nom build . && darwin-rebuild switch --flake .";
    };
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "podman"
      ];
    };
  };
}
