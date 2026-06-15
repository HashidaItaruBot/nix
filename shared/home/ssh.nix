_: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "Host github.com" = {
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
      };
    };
  };
}
