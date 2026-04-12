{
  inputs,
  ...
}:
{
  # Import the comfyui module from nixified-ai/flake
  imports = [
    inputs.nixified-ai.nixosModules.comfyui
  ];

  # Add nixified-ai overlays for comfyui
  nixpkgs.overlays = [
    inputs.nixified-ai.overlays.comfyui
    inputs.nixified-ai.overlays.models
    inputs.nixified-ai.overlays.fetchers
  ];

  # ComfyUI service configuration
  services.comfyui = {
    enable = true;
    # Uncomment one of below based on your GPU:
    # For NVIDIA GPUs:
    # acceleration = "cuda";
    # For AMD GPUs:
    # acceleration = "rocm";
    # For CPU only:
    acceleration = "rocm";
    # Listen on localhost only
    host = "127.0.0.1";
    port = 8188;
    # No models by default - add your models here if needed
    models = [ ];
    # No custom nodes by default - add your custom nodes here if needed
    customNodes = [ ];
    openFirewall = false;
  };
}
