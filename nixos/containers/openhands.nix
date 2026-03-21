{
  config,
  pkgs,
  self,
  ...
}:
{
  # OpenHands NixOS Container Configuration
  # 架构：nixos-container (外层隔离) + Docker (容器内运行)
  # 参考：CONTEXT.md 架构决策

  containers.openhands = {
    # OH-05: 开机自启
    autoStart = true;

    # 网络配置：NAT 模式
    privateNetwork = true;
    hostBridge = null; # NAT mode

    # OH-02: 端口转发 (宿主机 3000 -> 容器 3000)
    forwardPorts = [
      {
        containerPort = 3000;
        hostPort = 3000;
        protocol = "tcp";
      }
    ];

    # OH-04: 数据持久化 bind mount
    bindMounts = {
      "/var/lib/openhands" = {
        hostPath = "/var/lib/openhands";
        isReadOnly = false;
      };
      # SOPS 密钥挂载 - 挂载整个 /run/secrets 以包含符号链接目标
      # SOPS 创建符号链接: /run/secrets/openhands/LLM_API_KEY -> /run/secrets/openhands_llm_api_key
      # 需要挂载整个目录才能让容器内符号链接正常工作
      "/run/secrets" = {
        hostPath = "/run/secrets";
        isReadOnly = true;
      };
    };

    # 容器内配置
    config =
      { config, pkgs, ... }:
      {
        # OH-01: Docker 运行时
        virtualisation.docker.enable = true;

        # 网络配置
        networking.firewall.allowedTCPPorts = [ 3000 ];

        # OpenHands 服务 (Docker Compose)
        systemd.services.openhands = {
          description = "OpenHands AI Programming Assistant";
          wantedBy = [ "multi-user.target" ];
          after = [ "docker.service" ];
          requires = [ "docker.service" ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            WorkingDirectory = "/var/lib/openhands";
            # 复制 docker-compose.yml 到工作目录
            ExecStartPre = "${pkgs.coreutils}/bin/cp ${./docker-compose.yml} /var/lib/openhands/docker-compose.yml";
            ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d";
            ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
            # 从 SOPS secret 文件读取 LLM_API_KEY
            EnvironmentFile = "/run/secrets/openhands/LLM_API_KEY";
          };

          # LLM 配置 (阿里百炼 OpenAI 兼容)
          environment = {
            LLM_BASE_URL = "https://coding.dashscope.aliyuncs.com/v1";
            LLM_MODEL = "glm-5";
            # LLM_API_KEY 通过 EnvironmentFile 注入，格式: LLM_API_KEY=sk-xxx
          };
        };

        # 系统包
        environment.systemPackages = with pkgs; [
          docker-compose
        ];
      };
  };

  # 宿主机上创建数据目录
  systemd.tmpfiles.rules = [
    "d /var/lib/openhands 0755 root root -"
    "d /var/lib/openhands/data 0755 root root -"
    "d /var/lib/openhands/workspace 0755 root root -"
    # 不再需要创建 /run/secrets/openhands - SOPS 自动管理
  ];
}
