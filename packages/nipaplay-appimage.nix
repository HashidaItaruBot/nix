{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  appimage-run,
}:
stdenv.mkDerivation rec {
  pname = "nipaplay-reload";
  version = "1.10.13";

  src = fetchurl {
    url = "https://github.com/AimesSoft/NipaPlay-Reload/releases/download/v${version}/NipaPlay-${version}-Linux-amd64.AppImage";
    hash = "sha256-qdQEbgd0osfQIVMyq7UnODunFoX98FL3tu77G7odQio=";
  };

  dontUnpack = true;
  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib $out/share/applications
    ln -s "$src" $out/lib/nipaplay-reload.AppImage

    makeWrapper ${appimage-run}/bin/appimage-run $out/bin/nipaplay-reload \
      --add-flags "$out/lib/nipaplay-reload.AppImage"

    cat > $out/share/applications/io.github.MCDFsteve.NipaPlay-Reload.desktop << 'EOF'
    [Desktop Entry]
    Name=NipaPlay-Reload
    Comment=A modern cross-platform local video player with danmaku support
    Exec=nipaplay-reload
    Icon=nipaplay-reload
    Type=Application
    Categories=AudioVideo;Player;
    Terminal=false
    StartupNotify=false
    EOF
    runHook postInstall
  '';

  meta = with lib; {
    description = "A modern cross-platform local video player with danmaku support";
    homepage = "https://github.com/AimesSoft/NipaPlay-Reload";
    license = licenses.mit;
    mainProgram = "nipaplay-reload";
    platforms = ["x86_64-linux"];
  };
}
