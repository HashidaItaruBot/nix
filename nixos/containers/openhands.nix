{
  config,
  pkgs,
  self,
  ...
}:
{
  containers.openhands = {
    autoStart = true;

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

        networking.firewall.allowedTCPPorts = [ 3000 ];

        environment.systemPackages = with pkgs; [
          podman
          git
          bash
          coreutils
        ];

        programs.nix-ld.enable = true;

        systemd.services.init-task = {
          description = "OpenHands Initialization Task";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          path = with pkgs; [ podman ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.writeShellScript "container-init" ''
              podman run -d --rm --pull=always -e AGENT_SERVER_IMAGE_REPOSITORY=ghcr.io/openhands/agent-server -e AGENT_SERVER_IMAGE_TAG=1.12.0-python -e LOG_ALL_EVENTS=true -v /var/run/docker.sock:/var/run/docker.sock -v ~/.openhands:/.openhands -p 3000:3000 --add-host host.docker.internal:host-gateway --name openhands-app docker.openhands.dev/openhands/openhands:1.5
            ''}";
          };
        };

        system.stateVersion = "26.05";
      };
  };
}
