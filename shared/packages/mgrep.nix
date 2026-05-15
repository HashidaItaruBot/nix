{ lib, stdenv, fetchFromGitHub, fetchPnpmDeps, pnpmConfigHook, pnpm, nodejs, makeWrapper }:

stdenv.mkDerivation (finalAttrs: {
  pname = "mgrep";
  version = "0.1.13";

  src = fetchFromGitHub {
    owner = "mixedbread-ai";
    repo = "mgrep";
    rev = "v${finalAttrs.version}";
    hash = "sha256-uLAK4Mf0ghJmm6dHxooVuvMrZ16K9XZtedF5Cr/2DiM=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-vzXu09vZbNQgWm87y98m05EKPn+WO7m0HNkfS+wGqGU=";
  };

  nativeBuildInputs = [ nodejs pnpm pnpmConfigHook makeWrapper ];

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/node_modules/@mixedbread/mgrep
    cp -r dist node_modules package.json $out/lib/node_modules/@mixedbread/mgrep/
    makeWrapper ${nodejs}/bin/node $out/bin/mgrep \
      --add-flags "$out/lib/node_modules/@mixedbread/mgrep/dist/index.js"
    runHook postInstall
  '';

  meta = with lib; {
    description = "A calm, CLI-native way to semantically grep everything, like code, images, pdfs and more";
    homepage = "https://github.com/mixedbread-ai/mgrep";
    license = licenses.asl20;
    mainProgram = "mgrep";
  };
})
