_: {
  virtualisation.incus = {
    enable = true;
    # 首次启动时自动执行 `incus admin init --preseed`，免去交互初始化：
    # dir 存储池 + NAT 网桥 incusbr0，容器开箱即用。
    preseed = {
      config = {};
      networks = [
        {
          config = {
            "ipv4.address" = "10.100.0.1/24";
            "ipv4.nat" = "true";
          };
          description = "";
          name = "incusbr0";
          type = "bridge";
        }
      ];
      profiles = [
        {
          config = {
            "security.nesting" = "true";
          };
          description = "Default profile";
          devices = {
            eth0 = {
              name = "eth0";
              network = "incusbr0";
              type = "nic";
            };
            root = {
              path = "/";
              pool = "default";
              type = "disk";
            };
          };
          name = "default";
        }
      ];
      storage_pools = [
        {
          config = {};
          description = "";
          name = "default";
          driver = "dir";
        }
      ];
      projects = [];
    };
  };

  # incus-admin：完全管理权限；incus：普通 CLI 访问（经 polkit）
  users.users.zhaochanglong.extraGroups = [
    "incus"
    "incus-admin"
  ];
}
