{ config, self, pkgs, ... }:

{
  # 创建数据目录（node 用户 UID=1000）
  systemd.tmpfiles.rules = [
    "d /var/lib/openclaw 0755 1000 1000 -"
    "d /var/lib/openclaw/workspace 0755 1000 1000 -"
    "d /var/lib/openclaw/sandboxes 0755 1000 1000 -"
  ];

  # 自动生成 Gateway Token（如果不存在）
  systemd.services.openclaw-init = {
    description = "Initialize OpenClaw Gateway Token";
    wantedBy = [ "multi-user.target" ];
    before = [ "podman-openclaw.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      TOKEN_FILE="/var/lib/openclaw/.gateway_token"
      if [ ! -f "$TOKEN_FILE" ]; then
        ${pkgs.openssl}/bin/openssl rand -hex 32 > "$TOKEN_FILE"
        chown 1000:1000 "$TOKEN_FILE"
        chmod 600 "$TOKEN_FILE"
      fi
    '';
  };

  # OCI 容器配置
  virtualisation.oci-containers = {
    backend = "podman";

    containers.openclaw = {
      image = "ghcr.io/openclaw/openclaw:latest";
      autoStart = true;

      ports = [
        "18789:18789" # Gateway / Web UI
        "18790:18790" # Bridge
      ];

      volumes = [
        "/var/lib/openclaw:/home/node/.openclaw"
        "/var/lib/openclaw/workspace:/home/node/.openclaw/workspace"
        "/var/lib/openclaw/sandboxes:/home/node/.openclaw/sandboxes"
        "/run/podman/podman.sock:/var/run/docker.sock" # 挂载 Podman socket（沙箱模式）
      ];

      environment = {
        OPENCLAW_GATEWAY_BIND = "lan";
        # 沙箱模式配置
        OPENCLAW_SANDBOX = "1";
      };

      environmentFiles = [
        "/var/lib/openclaw/.gateway_token"
      ];

      extraOptions = [
        "--pull=always"
        "--health-cmd=curl -f http://127.0.0.1:18789/healthz"
        "--health-interval=30s"
        "--health-timeout=5s"
        "--health-retries=3"
        # 精细权限模式
        "--cap-add=SYS_ADMIN"
        "--security-opt=seccomp=unconfined"
      ];
    };
  };

  # 防火墙配置（LAN 访问）
  networking.firewall.allowedTCPPorts = [ 18789 18790 ];
}

