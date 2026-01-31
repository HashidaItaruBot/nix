{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Enable Ollama service with ROCm support for AMD GPU acceleration
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;

    # Note: acceleration is determined by the package (ollama-rocm)
    # No need to set acceleration option separately

    # Optional: Set listen address (default is localhost:11434)
    # listenAddress = "127.0.0.1:11434";

    # Optional: Set environment variables for Ollama
    environmentVariables = {
      # Set ROCm device (optional, defaults to all available)
      # HIP_VISIBLE_DEVICES = "0";

      # Increase timeout for large models
      OLLAMA_NUM_PARALLEL = "1";
      OLLAMA_MAX_LOADED_MODELS = "1";
    };
  };

  # Add Ollama to system packages for command line access
  environment.systemPackages = with pkgs; [
    ollama-rocm
  ];

  # Optional: Open firewall port if you want to access Ollama from other devices
  # networking.firewall.allowedTCPPorts = [ 11434 ];

  # Optional: Create a systemd service override for additional configuration
  # systemd.services.ollama = {
  #   serviceConfig = {
  #     # Increase memory limits for large models
  #     MemoryMax = "32G";
  #     MemorySwapMax = "64G";
  #   };
  # };
}
