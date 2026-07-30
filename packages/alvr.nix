{
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    alvr
  ];

  # ALVR 使用的端口
  networking.firewall.allowedTCPPorts = [9943 9944];
  networking.firewall.allowedUDPPorts = [9943];
}
