{ ... }: {
  programs.ssh.matchBlocks."*".identityAgent = "~/.1password/agent.sock";
  programs.ssh.matchBlocks."github.com".identityAgent = "~/.1password/agent.sock";
}
