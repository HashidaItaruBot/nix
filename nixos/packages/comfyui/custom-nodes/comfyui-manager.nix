{
  lib,
  fetchFromGitHub,
  python3,
}:

let
  pname = "comfyui-manager";
  version = "1.4.0";
  src = fetchFromGitHub {
    owner = "ltdrdata";
    repo = "ComfyUI-Manager";
    rev = version;
    hash = "sha256-1v8j6l1ibv06b414qhb671wymlb3z6bwnr40jpf6pm6837a8qmfm";
  };
in
python3.pkgs.buildPythonPackage {
  inherit pname version src;

  doCheck = false;

  # No build phase needed for ComfyUI custom nodes
  dontBuild = true;

  # Install the package as a ComfyUI custom node
  # Following the pattern from nixified-ai packages
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/comfyui/custom_nodes
    cp -r $src $out/share/comfyui/custom_nodes/ComfyUI-Manager

    runHook postInstall
  '';

  # Check requirements.txt from the repository
  propagatedBuildInputs = with python3.pkgs; [
    # ComfyUI-Manager may have dependencies
    # We'll need to check the actual requirements
  ];

  meta = with lib; {
    description = "ComfyUI Manager - A manager for custom nodes, models, and workflows in ComfyUI";
    homepage = "https://github.com/ltdrdata/ComfyUI-Manager";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };

  passthru = {
    comfyui = {
      # This tells ComfyUI where to install this custom node
      installPaths = [ "custom_nodes" ];
    };
  };
}
