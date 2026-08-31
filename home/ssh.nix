_: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      # 本地桌面：走 1Password agent。
      # 经 SSH 登录时（SSH_CONNECTION 非空）：不设 IdentityAgent，改用转发的 SSH_AUTH_SOCK。
      "Match exec \"test -z \\\"$SSH_CONNECTION\\\"\"" = {
        IdentityAgent = "~/.1password/agent.sock";
      };

      "Host github.com" = {
        HostName = "ssh.github.com";
        Port = 443;
        User = "git";
      };
    };
  };
}
