_: {
  programs.ssh = {
    # NixOS 使用 SSH Agent Forwarding，不需要指定 IdentityAgent
    # 让 SSH 使用默认的 $SSH_AUTH_SOCK (从 macOS 转发的 agent)
    matchBlocks = {};
  };
}
