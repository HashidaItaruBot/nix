{
  config,
  pkgs,
  self,
  ...
}:
{
  containers.openhands = {
    # OH-05: 开机自启
    autoStart = true;

    # 容器内配置
    config =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        virtualisation.podman = {
          enable = true;
          dockerCompat = true;
          dockerSocket.enable = true;
        };
        users.users.root.subUidRanges = [
          {
            startUid = 100000;
            count = 65536;
          }
        ];
        users.users.root.subGidRanges = [
          {
            startGid = 100000;
            count = 65536;
          }
        ];

        # 网络配置
        networking.firewall.allowedTCPPorts = [ 3000 ];

        # 系统包
        environment.systemPackages = with pkgs; [
          uv
          docker
          docker-compose
          podman
          podman-compose
          git
          bash
          coreutils
        ];

        programs.nix-ld.enable = true;

        systemd.services.init-task = {
          description = "OpenHands Initialization Task";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.writeShellScript "container-init" ''
              ${pkgs.uv}/bin/uv tool run openhands serve
            ''}";
          };
        };

        system.stateVersion = "26.05";
      };
  };
}
