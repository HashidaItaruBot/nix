_: {
  virtualisation.incus = {
    enable = true;
    agent.enable = true;
  };

  security.apparmor.enable = true;

  networking.firewall = {
    trustedInterfaces = [ "incusbr0" ];
    # 允许 Incus 网桥的 DHCP 和 DNS 流量
    allowedUDPPorts = [ 67 68 53 ];
    allowedTCPPorts = [ 53 ];
  };

  # 启用 NAT 以允许容器访问外部网络
  networking.nat = {
    enable = true;
    externalInterface = "eno1";
    internalInterfaces = [ "incusbr0" ];
  };
}
