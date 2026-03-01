{
  config,
  lib,
  pkgs,
  ...
}:

{
  # 启用用户命名空间（无根容器必需）
  security.unprivilegedUsernsClone = true;

  # Docker无根模式配置
  virtualisation.docker = {
    enable = false; # 禁用系统级Docker守护进程

    rootless = {
      enable = true;
      setSocketVariable = true; # 自动设置DOCKER_HOST环境变量

      # Docker守护进程配置
      daemon.settings = {
        storage-driver = "overlay2";
        log-opts = {
          max-size = "10m";
          max-file = "3";
        };
      };
    };
  };
}
