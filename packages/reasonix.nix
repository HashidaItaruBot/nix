{
  lib,
  stdenv,
  nodejs,
  fetchurl,
  makeWrapper,
}:
stdenv.mkDerivation rec {
  pname = "reasonix";
  version = "0.53.2";

  src = fetchurl {
    url = "https://registry.npmjs.org/reasonix/-/reasonix-${version}.tgz";
    hash = "sha256-JXphiOaJk62fCR4biIb/MeWQomVhQVJEaJnbsQ/kz2M=";
  };

  nativeBuildInputs = [makeWrapper];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/reasonix $out/bin
    cp -r * $out/lib/reasonix/

    makeWrapper ${nodejs}/bin/node $out/bin/reasonix \
      --add-flags "$out/lib/reasonix/dist/cli/index.js"
    makeWrapper ${nodejs}/bin/node $out/bin/dsnix \
      --add-flags "$out/lib/reasonix/dist/cli/index.js"
    runHook postInstall
  '';

  meta = with lib; {
    description = "DeepSeek-native coding agent: cache-first loop, flash-first cost control, tool-call repair";
    homepage = "https://github.com/esengine/DeepSeek-Reasonix";
    license = licenses.mit;
    mainProgram = "reasonix";
    platforms = platforms.unix;
  };
}
