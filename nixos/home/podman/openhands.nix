{ config, ... }:
{
  services.podman.containers.openhands = {
    autoStart = true;
    image = "docker.openhands.dev/openhands/openhands:1.5";
    environment = {
      AGENT_SERVER_IMAGE_REPOSITORY = "ghcr.io/openhands/agent-server";
      AGENT_SERVER_IMAGE_TAG = "1.12.0-python";
      LOG_ALL_EVENTS = true;
    };
    volumes = [
      "/run/user/1000/podman/podman.sock:/var/run/docker.sock"
      "${config.home.homeDirectory}/.openhands:/.openhands"
      "${config.home.homeDirectory}/Documents/nix:/workspace/project/nix"
    ];
    ports = [
      "3000:3000"
    ];
  };
}
