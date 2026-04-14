{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  # Get the comfyui infrastructure from the overlay
  comfyuiLib = pkgs.comfyuiLib;

  # Import custom nodes from separate files
  comfyui-manager = import ./custom-nodes/comfyui-manager.nix {
    inherit pkgs comfyuiLib;
  };

  customNodes = [
    # ComfyUI Manager - A powerful management tool for ComfyUI
    comfyui-manager
  ];
in
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
    # Custom nodes - imported from separate files for better modularity
    customNodes = customNodes;
    openFirewall = false;
  };
}
