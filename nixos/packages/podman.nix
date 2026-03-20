{ pkgs, lib, config, ... }:
{
  environment.systemPackages = with pkgs; [
    podman
    podman-compose
    podman-tui
  ];

  # Podman 容器运行时配置
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
}
