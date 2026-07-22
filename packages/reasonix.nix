{
  lib,
  stdenv,
  nodejs,
  fetchurl,
  makeWrapper,
}:
stdenv.mkDerivation rec {
  pname = "reasonix";
  version = "1.17.18";

  src = fetchurl {
    url = "https://registry.npmjs.org/reasonix/-/reasonix-${version}.tgz";
    hash = "sha256-+wjDPFeg3NJZ/KeUrW4FptdRkaz7ZmIcHGlBgfRLGHg=";
  };

  nativeSrc = fetchurl {
    url = "https://registry.npmjs.org/@reasonix/cli-linux-x64/-/cli-linux-x64-${version}.tgz";
    hash = "sha256-3VtfAzNiLgi1e5jqhGNK33sMrTICd7vptryxvQqculk=";
  };

  nativeBuildInputs = [makeWrapper];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/reasonix $out/bin

    # Extract main package (bin/reasonix.js launcher + package.json)
    tar xzf $src -C $out/lib/reasonix/ --strip-components=1

    # Extract native binary into node_modules
    mkdir -p $out/lib/reasonix/node_modules/@reasonix/cli-linux-x64
    tar xzf $nativeSrc -C $out/lib/reasonix/node_modules/@reasonix/cli-linux-x64/ --strip-components=1
    chmod +x $out/lib/reasonix/node_modules/@reasonix/cli-linux-x64/bin/reasonix

    makeWrapper ${nodejs}/bin/node $out/bin/reasonix \
      --add-flags "$out/lib/reasonix/bin/reasonix.js"
    runHook postInstall
  '';

  meta = with lib; {
    description = "DeepSeek-native coding agent: cache-first loop, flash-first cost control, tool-call repair";
    homepage = "https://github.com/esengine/DeepSeek-Reasonix";
    license = licenses.mit;
    mainProgram = "reasonix";
    platforms = platforms.linux;
  };
}
