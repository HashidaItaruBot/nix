{ ... }:
{
  programs.ssh.settings = {
    "Host *" = {
      identityAgent = "~/.1password/agent.sock";
    };
    "Host github.com" = {
      identityAgent = "~/.1password/agent.sock";
    };
  };
}
