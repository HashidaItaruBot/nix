# MaiBot（麦麦）+ NapCat
#
# 部署内容：
#   - maibot-core  : 麦麦主程序（LLM 聊天核心 + WebUI，宿主 18001 端口）
#   - maibot-napcat: NapCat QQ 协议端（登录机器人 QQ 号，WebUI 宿主 6099 端口）
#   - 网络 maibot  : 两个容器互通，core 通过 DNS 名 maibot-napcat:3001 连接 NapCat
#
# 数据目录：~/.config/maibot/（配置/数据/插件/日志/QQ 登录态均持久化于此）
#
# 首次启动后：
#   1. WebUI（麦麦）   http://localhost:18001 — Token 在容器日志里找：
#      systemctl --user status podman-maibot-core 或 podman logs maibot-core | grep Token
#   2. NapCat WebUI   http://localhost:6099 — 扫码登录机器人 QQ 号
#      （NapCat token 见容器日志 systemctl --user status podman-maibot-napcat）
#   3. 在麦麦 WebUI 配置模型 API，并安装「统一 QQ 连接器」插件
#      （MaiBot-SnowLuma-Adapter），其中 client.server 填 maibot-napcat、port 填 3001；
#      NapCat WebUI 里创建 OneBot 正向 WebSocket 服务监听 0.0.0.0:3001
{config, ...}: let
  dataDir = config.home.homeDirectory + "/.config/maibot";
in {
  services.podman.networks.maibot = {
    description = "MaiBot containers shared network (core <-> napcat)";
    driver = "bridge";
  };

  services.podman.containers.maibot-core = {
    image = "docker.io/sengokucola/maibot:latest";
    autoStart = true;
    network = "maibot.network";

    ports = [
      "0.0.0.0:18001:8001" # WebUI
    ];

    environment = {
      TZ = "Asia/Shanghai";
      EULA_AGREE = "8e6e7d647f7f82d6ea98456b73908656"; # 官方 compose 内置值，勿改
      PRIVACY_AGREE = "91e5db7659c560bc3545e63859b6ebc0"; # 官方 compose 内置值，勿改
      MAIBOT_LEGACY_0X_UPGRADE_CONFIRMED = "1"; # 无交互终端，跳过旧版迁移确认
      MAIBOT_STATISTICS_REPORT_PATH = "/MaiMBot/data/maibot_statistics.html";
      HTTP_HOST = "0.0.0.0"; # 容器内必须监听全部网卡，宿主机才能访问 WebUI
    };

    volumes = [
      "${dataDir}/config:/MaiMBot/config" # bot 配置（bot_config.toml 等）
      "${dataDir}/data:/MaiMBot/data" # 运行数据（含数据库）
      "${dataDir}/data/plugins-data:/MaiMBot/data/plugins" # 插件持久数据
      "${dataDir}/data/emoji:/data/emoji" # 表情包缓存
      "${dataDir}/plugins:/MaiMBot/plugins" # 插件源码
      "${dataDir}/logs:/MaiMBot/logs" # 日志
    ];

    extraConfig = {
      Service = {
        TimeoutStopSec = 70; # 官方 stop_grace_period：Runner 最多等 Worker 60s
        # quadlet 不像 compose 会自动创建宿主挂载目录，启动前先建好
        ExecStartPre = ["/run/current-system/sw/bin/mkdir -p ${dataDir}/config ${dataDir}/data ${dataDir}/data/plugins-data ${dataDir}/data/emoji ${dataDir}/plugins ${dataDir}/logs"];
      };
    };
  };

  services.podman.containers.maibot-napcat = {
    image = "docker.io/mlikiowa/napcat-docker:latest";
    autoStart = true;
    network = "maibot.network";
    networkAlias = ["napcat"];

    ports = [
      "0.0.0.0:6099:6099" # NapCat WebUI（扫码登录用）
    ];

    environment = {
      TZ = "Asia/Shanghai";
      NAPCAT_UID = "1000"; # 与宿主用户 UID 一致
      NAPCAT_GID = "1000";
    };

    volumes = [
      "${dataDir}/napcat/config:/app/napcat/config" # NapCat 配置（含 OneBot 监听设置）
      "${dataDir}/qq:/app/.config/QQ" # QQ 本体数据（登录态）
      "${dataDir}/data:/MaiMBot/data" # 与 core 共享数据目录
    ];

    extraConfig = {
      Service = {
        TimeoutStopSec = 30; # QQ 进程较多，给足优雅退出时间
        ExecStartPre = ["/run/current-system/sw/bin/mkdir -p ${dataDir}/napcat/config ${dataDir}/qq ${dataDir}/data"];
      };
    };
  };
}
