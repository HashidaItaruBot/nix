{ inputs
, pkgs
, lib
, ...
}:

{
  # MicroVM配置
  microvm = {
    hypervisor = "qemu";

    # 禁用QEMU图形窗口 - VM内部使用Xvfb虚拟显示即可
    # graphics.enable = true;

    # 可写Nix Store影子层 - 允许安装新nix程序
    # 主机/nix/store(只读) + 影子层(可写) → overlayfs合并
    writableStoreOverlay = "openclaw-store-overlay.img";

    # 存储配置 - 持久化数据
    volumes = [
      {
        mountPoint = "/var/lib/openclaw";
        image = "openclaw-state.img";
        size = 4096; # 4GB
      }
    ];

    # 网络配置 - 使用用户模式网络
    interfaces = [
      {
        type = "user";
        id = "openclaw-net";
        mac = "02:00:00:00:00:01";
      }
    ];

    # 端口转发 - 让主机可以访问VM内的服务
    forwardPorts = [
      {
        host.port = 18789;
        guest.port = 18789;
        proto = "tcp";
      }
      # SSH 端口转发 - 用于进入VM
      {
        host.port = 2222;
        guest.port = 22;
        proto = "tcp";
      }
    ];
  };

  # 启用 SSH 服务
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  # 开放 SSH 端口和openclaw的web管理界面
  networking.firewall.allowedTCPPorts = [ 18789 22 ];

  # 创建 root 用户密码（用于 SSH 登录）
  users.users.root.password = "openclaw";

  # 启用Nix守护进程 - 允许在VM内安装软件
  nix = {
    enable = true;
    settings = {
      trusted-users = [ "root" ];
      sandbox = false; # overlayfs环境下需要禁用sandbox
      # 启用实验性功能
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
    };
  };

  # 安装虚拟显示和浏览器相关依赖
  environment.systemPackages = with pkgs; [
    # OpenClaw CLI
    openclaw
    # 虚拟显示和浏览器
    xvfb
    chromium
    firefox
    noto-fonts
    noto-fonts-cjk-sans
    # 基本工具
    git
    curl
    wget
    vim
  ];

  # 设置虚拟显示环境
  environment.variables = {
    DISPLAY = ":99";
    QT_QPA_PLATFORM = "offscreen";
    GDK_BACKEND = "x11";
  };

  # OpenClaw Gateway服务
  services.openclaw-gateway = {
    enable = true;
    port = 18789;
  };

  system.stateVersion = "25.11";
}

