{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        identityAgent = "~/.1password/agent.sock";
      };

      "github.com" = {
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
        identityAgent = "~/.1password/agent.sock";
      };
    };
  };
}
