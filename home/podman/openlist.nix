{config, ...}: let
  dataDir = config.home.homeDirectory + "/.config/openlist";
in {
  services.podman.containers.openlist = {
    image = "docker.io/openlistteam/openlist:latest";
    user = "0:0";
    volumes = [
      "${dataDir}:/opt/openlist/data"
    ];
    ports = [
      "5244:5244"
    ];
    environment = {
      UMASK = "022";
    };
    autoStart = true;
  };
}
