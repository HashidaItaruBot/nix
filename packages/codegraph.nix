{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  autoPatchelfHook,
}: let
  version = "1.6.2";
  platform = "linux-x64";
  hash = "sha256-7wr0FgkhKPsczHI3hgALft9KaXH+YErNCL+Wbk83uCg=";
in
  stdenv.mkDerivation {
    pname = "codegraph";
    inherit version;

    src = fetchurl {
      url = "https://github.com/colbymchenry/codegraph/releases/download/v${version}/codegraph-${platform}.tar.gz";
      hash = hash;
    };

    nativeBuildInputs = [makeWrapper autoPatchelfHook];
    buildInputs = [stdenv.cc.cc.lib];

    sourceRoot = "codegraph-${platform}";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/lib/codegraph/bin
      cp -r lib node $out/lib/codegraph/
      install -Dm755 bin/codegraph $out/lib/codegraph/bin/codegraph

      ln -s $out/lib/codegraph/bin/codegraph $out/bin/codegraph

      runHook postInstall
    '';

    meta = with lib; {
      description = "Pre-indexed code knowledge graph for AI agents — local, token-efficient code navigation";
      homepage = "https://github.com/colbymchenry/codegraph";
      changelog = "https://github.com/colbymchenry/codegraph/releases/tag/v${version}";
      license = licenses.mit;
      mainProgram = "codegraph";
      platforms = ["aarch64-linux" "x86_64-linux"];
    };
  }
