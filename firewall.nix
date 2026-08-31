{
  networking = {
    nftables.enable = true;
    firewall.allowedTCPPorts = [
      8000 # SillyTavern
      5244 # Openlist
      12345 # intiface central
    ];
  };
}
