{ lib, stdenv, fetchFromGitHub, fetchPnpmDeps, pnpmConfigHook, pnpm, nodejs, makeWrapper }:

stdenv.mkDerivation (finalAttrs: {
  pname = "athena-core";
  version = "1.0.0-unstable-2026-05-15";

  src = fetchFromGitHub {
    owner = "Athena-AI-Lab";
    repo = "athena-core";
    rev = "9da5f8c671154348750a12faef625ca0e3ed9fa8";
    hash = "sha256-Lij6rVdqwNT9BEGQRx/2sTkS7aWtOwOBgrcxzU4DnXg=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname;
    version = "1.0.0";
    src = finalAttrs.src;
    fetcherVersion = 3;
    hash = "sha256-x4Zmw0JCsN/DrZYYxeLlLGpZDdrKzIXo9ftdirhGzMw=";
  };

  nativeBuildInputs = [ nodejs pnpm pnpmConfigHook makeWrapper ];

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/node_modules/athena-core
    cp -r dist node_modules package.json configs $out/lib/node_modules/athena-core/
    makeWrapper ${nodejs}/bin/node $out/bin/athena \
      --add-flags "$out/lib/node_modules/athena-core/dist/main.js"
    runHook postInstall
  '';

  meta = with lib; {
    description = "A General-Purpose AI Agent";
    homepage = "https://github.com/Athena-AI-Lab/athena-core";
    license = licenses.bsd3;
    mainProgram = "athena";
  };
})
