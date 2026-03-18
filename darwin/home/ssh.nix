_: {
  # 现有配置: 1Password SSH agent
  programs.ssh.matchBlocks."*".identityAgent =
    "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
  programs.ssh.matchBlocks."github.com".identityAgent =
    "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";

  # 新增: NixOS 主机 ForwardAgent 配置
  programs.ssh.matchBlocks."nixos" = {
    hostname = "172.24.2.76";
    user = "zhaochanglong";
    forwardAgent = true;
  };
}
