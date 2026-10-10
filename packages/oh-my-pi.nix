{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "oh-my-pi";
  version = "18.8.8";

  src = fetchurl {
    url = "https://github.com/can1357/oh-my-pi/releases/download/v${finalAttrs.version}/omp-linux-x64";
    hash = "sha256-jYBHYbftGmkQpig/fE32WMjj68MgiGRyyQ1iar+i2Yg=";
  };

  strictDeps = true;
  dontUnpack = true;

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/omp
    runHook postInstall
  '';

  # strip 会删掉 bun 编译进二进制的 JS bundle
  dontStrip = true;

  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];
  doInstallCheck = true;

  meta = {
    description = "Coding agent for the terminal with LSP, debugging, and multi-provider LLM support";
    homepage = "https://omp.sh";
    changelog = "https://github.com/can1357/oh-my-pi/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "omp";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
