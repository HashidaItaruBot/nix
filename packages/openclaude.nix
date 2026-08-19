{
  lib,
  stdenv,
  fetchurl,
  bun,
  nodejs_22,
  makeWrapper,
  autoPatchelfHook,
  vips,
}: let
  pname = "openclaude";
  version = "0.29.0";
  src = fetchurl {
    url = "https://github.com/Gitlawb/openclaude/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-eoc5rbK44SvkVbf4NIn6L7hTmOFruT6v34WzjbJDbBc=";
  };

  # Fixed-output derivation to pre-fetch node_modules in sandbox
  nodeModules = stdenv.mkDerivation {
    name = "${pname}-${version}-node-modules";
    inherit src;
    nativeBuildInputs = [bun];
    dontPatchShebangs = true;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-TZ3wMp/ku5E6+KKwKOndV63t2ksVDzYYYX8OmxlyTDk=";

    buildPhase = ''
      export HOME=$TMPDIR
      bun install --frozen-lockfile
    '';

    installPhase = ''
      mkdir -p $out
      # Remove musl-specific sharp binaries — they can't link on glibc NixOS
      rm -rf node_modules/@img/sharp-linuxmusl-x64 node_modules/@img/sharp-libvips-linuxmusl-x64
      cp -r node_modules $out/
    '';
  };
in
  stdenv.mkDerivation {
    inherit pname version src;

    nativeBuildInputs =
      [bun makeWrapper]
      ++ lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];
    buildInputs = lib.optionals stdenv.hostPlatform.isLinux [vips];

    buildPhase = ''
      runHook preBuild
      export HOME=$TMPDIR
      ln -sf ${nodeModules}/node_modules node_modules
      bun run build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/openclaude $out/bin
      cp -r dist $out/lib/openclaude/
      cp -r ${nodeModules}/node_modules $out/lib/openclaude/
      chmod -R u+w $out/lib/openclaude/node_modules/@img
      # Remove musl-specific sharp binaries — they can't link on glibc NixOS
      rm -rf $out/lib/openclaude/node_modules/@img/sharp-linuxmusl-x64 \
             $out/lib/openclaude/node_modules/@img/sharp-libvips-linuxmusl-x64
      cp -r bin $out/lib/openclaude/
      cp package.json $out/lib/openclaude/

      makeWrapper ${nodejs_22}/bin/node $out/bin/openclaude \
        --add-flags "$out/lib/openclaude/bin/openclaude"
      runHook postInstall
    '';

    meta = with lib; {
      description = "OpenClaude — Claude Code with any LLM provider (200+ models)";
      homepage = "https://github.com/Gitlawb/openclaude";
      license = licenses.unfree;
      mainProgram = "openclaude";
      platforms = platforms.unix;
    };
  }
