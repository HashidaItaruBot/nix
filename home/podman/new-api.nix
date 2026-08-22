{config, ...}: let
  dataDir = config.home.homeDirectory + "/.config/new-api";
in {
  services.podman.containers.new-api-postgres = {
    image = "docker.io/library/postgres:16-alpine";
    network = "new-api.network";
    networkAlias = ["new-api-postgres"];
    volumes = [
      "new-api-postgres.volume:/var/lib/postgresql/data"
    ];
    environment = {
      POSTGRES_DB = "new_api";
      POSTGRES_USER = "new_api";
      POSTGRES_HOST_AUTH_METHOD = "trust";
    };
    autoStart = true;
  };

  services.podman.containers.new-api = {
    image = "docker.io/calciumion/new-api:latest";
    network = "new-api.network";
    volumes = [
      "${dataDir}:/data"
    ];
    ports = [
      "0.0.0.0:3000:3000"
    ];
    environment = {
      SQL_DSN = "postgresql://new_api@new-api-postgres:5432/new_api";
      TZ = "Asia/Shanghai";
    };
    autoStart = true;
  };
}
