# ComfyUI Manager - A powerful management tool for ComfyUI
# Repository: https://github.com/ltdrdata/ComfyUI-Manager
{
  pkgs,
  comfyuiLib,
  ...
}:
let
  # Use nodePropsFromNpinSource to get correct properties from git source
  nodeProps = comfyuiLib.nodePropsFromNpinSource {
    type = "Git";
    repository = {
      type = "GitHub";
      owner = "ltdrdata";
      repo = "ComfyUI-Manager";
    };
    revision = "15ec9a901b47953f686805674bba26da65cd252b";
    hash = "sha256-7mXwEiLESapSDiqHL7FM2SdXd7XtY2TDR2Y5ZppRzvs=";
  };

  # Create the derivation
  package = pkgs.stdenv.mkDerivation nodeProps;

  # Wrap it as a comfyui custom node
  comfyui-manager = comfyuiLib.mkComfyUICustomNode package;
in
comfyui-manager
