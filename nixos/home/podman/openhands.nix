{ config, ... }:
{
  services.podman.containers.openhands = {
    image = "docker.openhands.dev/openhands/openhands:1.5";
    environment = {
      AGENT_SERVER_IMAGE_REPOSITORY = "ghcr.io/openhands/agent-server";
      AGENT_SERVER_IMAGE_TAG = "1.12.0-python";
      LOG_ALL_EVENTS = true;
    };
    volumes = [
      "${config.xdg.runtimeDir}/podman.sock:/var/run/docker.sock"
      "${config.home.homeDirectory}/.openhands:/.openhands"
    ];
    ports = [
      "3000:3000"
    ];
  };
}
