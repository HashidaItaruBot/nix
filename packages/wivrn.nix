{
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    wivrn
    xrizer
    wayvr
  ];

  # WiVRn 端口
  networking.firewall.allowedTCPPorts = [9757];
  networking.firewall.allowedUDPPorts = [9757];
}
