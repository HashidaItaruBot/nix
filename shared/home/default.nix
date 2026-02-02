_: {
  imports = [
    ./kitty.nix
    ./ssh.nix
    ./git.nix
    ./tmux
    ./zsh.nix
    ./direnv.nix
  ];

  home.username = "zhaochanglong";

  home.stateVersion = "24.05";
}
