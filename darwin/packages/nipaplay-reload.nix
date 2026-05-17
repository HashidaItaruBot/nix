{
  lib,
  stdenv,
  fetchurl,
  _7zz,
}:

let
  version = "1.10.5";
in
stdenv.mkDerivation rec {
  pname = "nipaplay-reload";
  inherit version;

  src = fetchurl {
    url = "https://github.com/AimesSoft/NipaPlay-Reload/releases/download/v${version}/NipaPlay_${version}_macOS_Universal.dmg";
    sha256 = "7c5ced42bfecf36cc9762ce8fc5722a812476a297a33f5972df33c1c8c4a403a";
  };

  nativeBuildInputs = [ _7zz ];

  unpackPhase = ''
    runHook preUnpack
    7zz x -y "$src"
    runHook postUnpack
  '';

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    cp -pR "NipaPlay.app" "$out/Applications/NipaPlay.app"
    runHook postInstall
  '';

  meta = with lib; {
    description = "A modern cross-platform local video player with danmaku, subtitle, and Emby/Jellyfin support";
    homepage = "https://github.com/AimesSoft/NipaPlay-Reload";
    license = licenses.mit;
    platforms = platforms.darwin;
    mainProgram = "nipaplay-reload";
  };
}
