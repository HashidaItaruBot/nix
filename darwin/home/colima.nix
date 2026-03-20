{ pkgs, lib, config, ... }:

let
  cfg = config.programs.colima;
in
{
  options.programs.colima = {
    enable = lib.mkEnableOption "Colima container runtime";

    memory = lib.mkOption {
      type = lib.types.int;
      default = 8;
      description = "Memory in GB";
    };

    cpu = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = "Number of CPUs";
    };

    disk = lib.mkOption {
      type = lib.types.int;
      default = 100;
      description = "Disk size in GB";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      colima
      docker
      docker-compose
    ];

    launchd.user.agents.colima = {
      serviceConfig = {
        ProgramArguments = [
          "/bin/sh" "-c"
          ''
            # 检查 colima 是否已运行
            if ! colima status &> /dev/null; then
              # 检查是否已有配置
              if [ -f ~/.colima/default/colima.yaml ]; then
                colima start
              else
                colima start --memory ${toString cfg.memory} --cpu ${toString cfg.cpu} --disk ${toString cfg.disk}
              fi
            fi
          ''
        ];
        RunAtLoad = true;
        KeepAlive = {
          SuccessfulExit = false;
        };
        StartInterval = 300;
      };
    };
  };
}
