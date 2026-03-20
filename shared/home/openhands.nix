{ pkgs, lib, config, ... }:

let
  cfg = config.programs.openhands;
in
{
  options.programs.openhands = {
    enable = lib.mkEnableOption "OpenHands AI assistant";

    image = lib.mkOption {
      type = lib.types.str;
      default = "ghcr.io/openhands/openhands:latest";
      description = "OpenHands Docker image";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 3000;
      description = "Web UI port";
    };

    llmModel = lib.mkOption {
      type = lib.types.str;
      default = "alibaba/qwen-plus";
      description = "LLM model to use";
    };

    llmBaseurl = lib.mkOption {
      type = lib.types.str;
      default = "https://dashscope.aliyuncs.com/compatible-mode/v1";
      description = "LLM API base URL";
    };

    apiKey = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "LLM API key (or set via environment variable)";
    };

    workspace = lib.mkOption {
      type = lib.types.path;
      default = "${config.home.homeDirectory}/openhands-workspace";
      description = "Workspace directory";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      colima
      docker
      docker-compose
    ];

    systemd.user.services.openhands = lib.mkIf pkgs.stdenv.isLinux {
      Unit = {
        Description = "OpenHands AI Assistant";
        After = [ "docker.service" ];
      };

      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = ''
          ${pkgs.docker}/bin/docker run -d --rm \
            --name openhands \
            -p ${toString cfg.port}:${toString cfg.port} \
            -v ${config.home.homeDirectory}/.openhands:/.openhands \
            -v ${cfg.workspace}:/workspace \
            -e LLM_MODEL="${cfg.llmModel}" \
            -e LLM_BASE_URL="${cfg.llmBaseurl}" \
            -e LLM_API_KEY="${cfg.apiKey}" \
            ${cfg.image}
        '';
        ExecStop = "${pkgs.docker}/bin/docker stop openhands";
      };

      Install.WantedBy = [ "default.target" ];
    };

    launchd.user.agents.openhands = lib.mkIf pkgs.stdenv.isDarwin {
      environment = {
        LLM_MODEL = cfg.llmModel;
        LLM_BASE_URL = cfg.llmBaseurl;
        LLM_API_KEY = cfg.apiKey;
      };

      serviceConfig = {
        ProgramArguments = [
          "/bin/sh" "-c"
          ''
            docker run -d --rm \
              --name openhands \
              -p ${toString cfg.port}:${toString cfg.port} \
              -v ${config.home.homeDirectory}/.openhands:/.openhands \
              -v ${cfg.workspace}:/workspace \
              -e LLM_MODEL="${cfg.llmModel}" \
              -e LLM_BASE_URL="${cfg.llmBaseurl}" \
              -e LLM_API_KEY="${cfg.apiKey}" \
              ${cfg.image}
          ''
        ];
        RunAtLoad = true;
        KeepAlive = false;
      };
    };
  };
}
