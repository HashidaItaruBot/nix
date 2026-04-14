{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

with lib;

let
  # Create the comfyui-manager custom node package
  comfyui-manager-package = pkgs.callPackage ./custom-nodes/comfyui-manager.nix { };

  # Helper to check if comfyui is enabled
  comfyuiEnabled = config.services.comfyui.enable or false;
in
{
  # Ensure comfyui module is imported
  imports = [
    # Import the comfyui module if it's not already imported
    (mkIf (!comfyuiEnabled) inputs.nixified-ai.nixosModules.comfyui)
  ];

  # Add nixified-ai overlays if comfyui is not already configured
  nixpkgs.overlays = mkIf (!comfyuiEnabled) [
    inputs.nixified-ai.overlays.comfyui
    inputs.nixified-ai.overlays.models
    inputs.nixified-ai.overlays.fetchers
  ];

  # ComfyUI configuration for manager
  services.comfyui = {
    enable = mkDefault true;

    # Add comfyui-manager to custom nodes
    customNodes = [ comfyui-manager-package ];
  };

  # Add the package to environment for manual installation if needed
  environment.systemPackages = optional comfyuiEnabled comfyui-manager-package;
}
