{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs_24,
  pnpm_10,
  pnpmConfigHook,
  fetchPnpmDeps,
  makeWrapper,
}: let
  pname = "zcode-cli";
  version = "3.17.1";
  src = fetchFromGitHub {
    owner = "zai-org";
    repo = "ZCode";
    tag = "v${version}";
    hash = "sha256-JqWkR8/OhubCIo7VaikpLj7KPNg26ygq9qLMqHFeZGA=";
  };
in
  stdenv.mkDerivation (finalAttrs: {
    inherit pname version src;

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = pnpm_10;
      fetcherVersion = 4;
      hash = "sha256-nEW8/4RtBzO/uOlDQ9ICa10fic4J+Osml6nEB6faREk=";
    };

    nativeBuildInputs = [
      nodejs_24
      pnpm_10
      pnpmConfigHook
      makeWrapper
    ];

    # pnpmConfigHook 只 patch 根 node_modules；workspace 子包 .bin 是 symlink，需解析目标补 patch
    preBuild = ''
      patchNodeBins() {
        for d in "$@"; do
          [ -d "$d" ] || continue
          for f in "$d"/*; do
            [ -e "$f" ] || continue
            if [ -L "$f" ]; then
              t=$(readlink -f "$f")
              [ -f "$t" ] && patchShebangs "$t"
            else
              patchShebangs "$f"
            fi
          done
        done
      }
      patchNodeBins node_modules/.bin */node_modules/.bin packages/*/node_modules/.bin apps/*/packages/*/node_modules/.bin
    '';

    buildPhase = ''
      runHook preBuild
      export HOME=$TMPDIR
      export PNPM_HOME=$TMPDIR/pnpm-home
      export CI=true
      # lockfile v9 + packageManager@10.33.2；禁用运行时自动下载 pnpm 10.33.2（沙箱无网络）
      export npm_config_manage_package_manager_versions=false
      pnpm --filter @zcode/cli... build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/zcode-cli $out/bin
      cp -r apps/zcode-cli/packages/cli/dist $out/lib/zcode-cli/dist
      makeWrapper ${nodejs_24}/bin/node $out/bin/zcode \
        --add-flags "$out/lib/zcode-cli/dist/zcode.cjs"
      runHook postInstall
    '';

    meta = with lib; {
      description = "ZCode Agent CLI - Z.ai's coding agent terminal client";
      homepage = "https://github.com/zai-org/ZCode";
      license = licenses.asl20;
      mainProgram = "zcode";
      platforms = platforms.unix;
    };
  })
