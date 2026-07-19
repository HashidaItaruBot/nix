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

  icon = fetchurl {
    url = "https://raw.githubusercontent.com/AimesSoft/NipaPlay-Reload/v${version}/assets/images/logo512.png";
    hash = "sha256-DQEpLrzapzsGgnmfEIKjMyC4jwWfdeFU60x4CP/aqhM=";
  };

  dontUnpack = true;
  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib $out/share/{applications,icons/hicolor/512x512/apps}
    ln -s "$src" $out/lib/nipaplay-reload.AppImage
    install -Dm644 "$icon" $out/share/icons/hicolor/512x512/apps/nipaplay-reload.png

    makeWrapper ${appimage-run}/bin/appimage-run $out/bin/nipaplay-reload \
      --add-flags "$out/lib/nipaplay-reload.AppImage" \
      --set GDK_PIXBUF_MODULE_FILE /dev/null

    cat > $out/share/applications/io.github.MCDFsteve.NipaPlay-Reload.desktop << EOF
    [Desktop Entry]
    Name=NipaPlay-Reload
    Comment=A modern cross-platform local video player with danmaku support
    Exec=nipaplay-reload
    Icon=$out/share/icons/hicolor/512x512/apps/nipaplay-reload.png
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
