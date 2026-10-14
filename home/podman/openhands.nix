# OpenHands Agent Canvas — 自托管编码代理控制中心 (Web UI)
# 地址: http://127.0.0.1:8000  (Canvas UI 在 /canvas 路径)
# 注意: 代理对 /projects 有完整读写权限, 挂载范围即信任边界
{config, ...}: let
  stateDir = config.home.homeDirectory + "/.openhands";
  projectsDir = config.home.homeDirectory + "/projects";
in {
  # rootless podman 不会自动创建 bind mount 源目录, 必须先于容器存在
  systemd.user.tmpfiles.rules = [
    "d ${stateDir} 0755 - - -"
    "d ${projectsDir} 0755 - - -"
  ];

  services.podman.containers.openhands = {
    # 镜像版本由 OpenHands README 的 x-release-please-version 标注, 升级需同步
    image = "ghcr.io/openhands/agent-canvas:1.27.1";
    # 容器 root → rootless podman 映射到宿主用户 (uid 1000), 与 Documents/.openhands 属主一致
    user = "0:0";
    volumes = [
      "${stateDir}:/home/openhands/.openhands"
      # 挂载即信任边界: 只授权 ~/projects, 处理其他目录需在此显式加 volumes
      "${projectsDir}:/projects"
    ];
    # 仅回环发布, 避免局域网直连
    ports = ["127.0.0.1:8000:8000"];
    environment = {
      # 官方 quickstart 值: UI 自动注入会话 key
      AGENT_CANVAS_ALLOW_LAN_SESSION_KEY = "true";
      PROJECTS_PATH = "/projects";
    };
    autoStart = true;
  };
}
