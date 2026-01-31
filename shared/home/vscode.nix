{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-python.python
      rust-lang.rust-analyzer
      golang.go
      ms-vscode.cpptools
      dbaeumer.vscode-eslint
      esbenp.prettier-vscode
      eamodio.gitlens
      ms-azuretools.vscode-docker
      redhat.vscode-yaml
      ms-vscode-remote.remote-ssh
    ];
  };
}