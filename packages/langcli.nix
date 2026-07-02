{
  lib,
  stdenv,
  nodejs,
  fetchurl,
  makeWrapper,
  autoPatchelfHook,
  alsa-lib,
}:
stdenv.mkDerivation rec {
  pname = "langcli";
  version = "0.1.39";

  src = fetchurl {
    url = "https://registry.npmjs.org/langcli-com/-/langcli-com-${version}.tgz";
    hash = "sha256-TQciZ7C9gBDn/zAQAO6Ze6OeH6zgKkzp+84UELxyhmY=";
  };

  nativeBuildInputs = [makeWrapper] ++ lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
    alsa-lib
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/langcli $out/bin
    cp -r * $out/lib/langcli/

    chmod +x $out/lib/langcli/dist/vendor/ripgrep/*/* 2>/dev/null || true
    chmod +x $out/lib/langcli/dist/vendor/audio-capture/*/*.node 2>/dev/null || true

    makeWrapper ${nodejs}/bin/node $out/bin/langcli \
      --add-flags "$out/lib/langcli/dist/cli.js"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Langcli - interactive AI coding assistant in the terminal";
    homepage = "https://github.com/LangcliTeam/langcli";
    license = licenses.unfree;
    mainProgram = "langcli";
    platforms = platforms.unix;
  };
}
