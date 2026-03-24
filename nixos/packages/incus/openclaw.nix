_: {
  networking.firewall = {
    enable = true;
    # 允许外部访问宿主机的 18789 端口
    allowedTCPPorts = [ 18789 ];
  };
}
