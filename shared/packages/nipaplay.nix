{ lib, stdenv, fetchurl, makeWrapper, _7zz }:

let
  version = "1.10.5";
in
stdenv.mkDerivation rec {
  pname = "nipaplay";
  inherit version;

  src =
    if stdenv.isDarwin then
      fetchurl {
        url = "https://github.com/AimesSoft/NipaPlay-Reload/releases/download/v${version}/NipaPlay_${version}_macOS_Universal.dmg";
        sha256 = "7c5ced42bfecf36cc9762ce8fc5722a812476a297a33f5972df33c1c8c4a403a";
      }
    else if stdenv.isLinux then
      fetchurl {
        url = "https://github.com/AimesSoft/NipaPlay-Reload/releases/download/v${version}/NipaPlay-${version}-Linux-amd64.tar.gz";
        hash = "sha256-FMyOy3fLzNW89kGjL2fTMmAh9GVk2Onm9sNzycKkjXQ=";
      }
    else
      throw "Unsupported platform for nipaplay: ${stdenv.hostPlatform.system}";

  nativeBuildInputs = [ makeWrapper ] ++ lib.optionals stdenv.isDarwin [ _7zz ];

  unpackPhase = ''
    runHook preUnpack
  ''
  + (if stdenv.isDarwin then ''
    7zz x -y "$src"
  '' else ''
    tar xzf "$src"
  '')
  + ''
    runHook postUnpack
  '';

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
  ''
  + (if stdenv.isDarwin then ''
    mkdir -p "$out/Applications"
    cp -pR "NipaPlay.app" "$out/Applications/NipaPlay.app"
  '' else ''
    mkdir -p "$out/bin" "$out/opt/nipaplay"
    cp NipaPlay "$out/opt/nipaplay/"
    cp -r lib "$out/opt/nipaplay/"
    cp -r data "$out/opt/nipaplay/"
    makeWrapper "$out/opt/nipaplay/NipaPlay" "$out/bin/nipaplay" \
      --prefix LD_LIBRARY_PATH : "$out/opt/nipaplay/lib" \
      --chdir "$out/opt/nipaplay"
  '')
  + ''
    runHook postInstall
  '';

  meta = with lib; {
    description = "A modern cross-platform local video player with danmaku, subtitle, and Emby/Jellyfin support";
    homepage = "https://github.com/AimesSoft/NipaPlay-Reload";
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "nipaplay";
  };
}
