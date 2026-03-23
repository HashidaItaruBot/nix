_: {
  virtualisation.incus = {
    enable = true;
    agent.enable = true;
  };

  networking.firewall = {
    trustedInterfaces = [ "incusbr0" ];
  };

  # 启用 NAT 以允许容器访问外部网络
  networking.nat = {
    enable = true;
    externalInterface = "eno1";
    internalInterfaces = [ "incusbr0" ];
  };
}
