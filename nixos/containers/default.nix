# NixOS Containers Module
# Exports all container configurations
#
# OpenClaw 容器配置说明：
# =========================
# 1. 此配置创建一个名为 "openclaw" 的 NixOS 容器
# 2. 容器内运行 OpenClaw Gateway 服务和 Podman
# 3. 容器使用私有网络 (192.168.100.11)
# 4. 使用现有的 sops secrets:
#    - telegram_bot_token (telegram_bot_token.yaml)
#    - alibaba_api_key (api_keys.yaml)
#
# 使用命令：
# - 查看容器状态: systemctl status container@openclaw
# - 进入容器: nixos-container root-login openclaw
# - 查看日志: journalctl -M openclaw -f
# - 重启容器: nixos-container restart openclaw
{ inputs
, self
, config
, lib
, pkgs
, ...
}: {
  # 启用容器支持
  boot.enableContainers = true;
  virtualisation.containers.enable = true;

  # 配置NAT网络，让容器可以访问外网
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-+" ];
    # 注意：需要根据实际网络接口调整，可以用 `ip link` 查看
    # 常见接口名: eth0, enp3s0, wlan0 等
    externalInterface = "eno1";
    enableIPv6 = true;
  };

  # OpenClaw 容器配置
  containers.openclaw = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";
    hostAddress6 = "fc00::1";
    localAddress6 = "fc00::2";

    # 启用TUN设备以支持嵌套容器 (Podman)
    enableTun = true;

    # 绑定挂载secrets（从主机的sops解密路径）
    bindMounts = {
      "/run/secrets/telegram_bot_token" = {
        hostPath = config.sops.secrets.telegram_bot_token.path;
        isReadOnly = true;
      };
      "/run/secrets/alibaba_api_key" = {
        hostPath = config.sops.secrets.alibaba_api_key.path;
        isReadOnly = true;
      };
    };

    config =
      { config
      , pkgs
      , lib
      , ...
      }: {
        # 导入nix-openclaw的NixOS模块
        imports = [
          inputs.nix-openclaw.nixosModules.openclaw-gateway
        ];

        # 容器基本配置
        boot.isContainer = true;
        networking.useHostResolvConf = lib.mkForce false;
        services.resolved.enable = true;

        # 启用Podman（容器内的容器运行时）
        # 这允许 OpenClaw 在容器内运行 Docker 容器
        virtualisation.podman = {
          enable = true;
          dockerCompat = true; # 提供 docker 命令别名
          defaultNetwork.settings.dns_enabled = true;
          autoPrune = {
            enable = true;
            dates = "weekly";
          };
        };

        # OpenClaw Gateway 服务配置
        services.openclaw-gateway = {
          enable = true;
          port = 18789;
          # 使用nix-openclaw提供的包
          package = inputs.nix-openclaw.packages.${pkgs.system}.openclaw-gateway;

          # OpenClaw JSON 配置
          config = {
            # Gateway 配置
            gateway = {
              mode = "local";
              auth.token = "openclaw-gateway-local-token";
            };

            # Telegram 配置
            channels.telegram = {
              tokenFile = "/run/secrets/telegram_bot_token";
              # 允许的用户ID（从 @userinfobot 获取）
              # 示例: allowFrom = [ 123456789 ];
              allowFrom = [ ];
              groups."*".requireMention = true;
            };

            # AI提供商配置 - 阿里百炼
            providers.alibaba = {
              apiKeyFile = "/run/secrets/alibaba_api_key";
            };
          };

          # 服务PATH中包含podman和相关工具
          servicePath = with pkgs; [
            podman
            curl
            jq
            git
            ripgrep
          ];
        };

        # 开放防火墙端口
        networking.firewall.allowedTCPPorts = [
          18789 # OpenClaw Gateway
        ];

        # 系统状态版本
        system.stateVersion = "25.11";
      };
  };
}
