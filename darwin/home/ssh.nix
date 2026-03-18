_: {
  programs.ssh.matchBlocks."*".identityAgent =
    "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
  programs.ssh.matchBlocks."github.com".identityAgent =
    "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
  programs.ssh.matchBlocks."github.com"."172.24.2.76".forwardAgent = "yes";
}
