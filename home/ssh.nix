_: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "Host *" = {
        identityAgent = "~/.1password/agent.sock";
      };
      "Host github.com" = {
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
        identityAgent = "~/.1password/agent.sock";
      };
    };
  };
}
