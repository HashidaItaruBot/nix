{ config, pkgs, ... }:

{
  # Firewall configuration for vLLM API port
  networking.firewall.allowedTCPPorts = [ 8000 ];

  # Data directories for models and cache
  systemd.tmpfiles.rules = [
    "d /var/lib/vllm 0755 root root -"
    "d /var/lib/vllm/models 0755 root root -"
    "d /var/lib/vllm/cache 0755 root root -"
  ];

  # vLLM inference service with ROCm GPU passthrough
  systemd.services.vllm = {
    description = "vLLM Inference Server with ROCm";
    wantedBy = [ "multi-user.target" ];
    after = [ "podman.service" ];
    requires = [ "podman.service" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.podman}/bin/podman run \
        --name vllm-server \
        --rm \
        --device /dev/kfd \
        --device /dev/dri \
        -e HIP_VISIBLE_DEVICES=1 \
        -e ROCR_VISIBLE_DEVICES=1 \
        -e HSA_OVERRIDE_GFX_VERSION=10.3.0 \
        -p 8000:8000 \
        -v /var/lib/vllm/models:/models:ro \
        -v /var/lib/vllm/cache:/root/.cache \
        rocm/vllm-dev:base \
        --model /models/Qwen2.5-7B-Instruct \
        --host 0.0.0.0 \
        --port 8000 \
        --dtype auto \
        --gpu-memory-utilization 0.9";
      ExecStop = "${pkgs.podman}/bin/podman stop -t 30 vllm-server";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };
}