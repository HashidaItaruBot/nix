_: {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      ChallengeResponseAuthentication = false;
      PermitRootLogin = "no";
      PubkeyAuthentication = true;
      AuthorizedKeysFile = "%h/.ssh/authorized_keys";
      AllowAgentForwarding = true;
    };
  };

  networking.firewall.allowedTCPPorts = [22];
}
