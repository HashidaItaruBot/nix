_: {
  virtualisation.incus = {
    enable = true;
    agent.enable = true;
  };

  networking.firewall.trustedInterfaces = [ "incusbr0" ];
}
