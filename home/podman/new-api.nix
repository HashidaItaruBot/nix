{config, ...}: let
  dataDir = config.home.homeDirectory + "/.config/new-api";
in {
  services.podman.containers.new-api = {
    image = "docker.io/calciumion/new-api:latest";
    volumes = [
      "${dataDir}:/data"
    ];
    ports = [
      "0.0.0.0:3000:3000"
    ];
    environment = {
      "TZ"="Asia/Shanghai";
    };
    autoStart = true;
  };
}
