{
  networking = {
    nftables.enable = true;
    # incusbr0 (incus NAT 网桥)：dnsmasq 的 DHCP/DNS 服务要求宿主机放行入站，
    # 否则虚拟机拿不到 IPv4、也无法解析域名（RA 是主动发的所以只有 IPv6 能配上）
    firewall.trustedInterfaces = [ "incusbr0" ];
    firewall.allowedTCPPorts = [
      8000 # SillyTavern
      5244 # Openlist
      12345 # intiface central
    ];
  };
}
