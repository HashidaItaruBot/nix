{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  lzip,
  python3,
  makeWrapper,
}:
stdenvNoCC.mkDerivation {
  pname = "waydroid-script";
  version = "0-unstable-2026-09-11";

  src = fetchFromGitHub {
    owner = "casualsnek";
    repo = "waydroid_script";
    rev = "48dbfaf34a6ddbe78688c530f9ba1c26522aafb2";
    hash = "sha256-UBbnYhiRCf4sMwpEDMlpJuTEsN66B2hZ8BPz6cCGXAc=";
  };

  nativeBuildInputs = [makeWrapper];
  buildInputs = [
    (python3.withPackages (ps: with ps; [tqdm requests inquirerpy]))
  ];

  postPatch = ''
    patchShebangs main.py
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/libexec
    cp -r . $out/libexec/waydroid_script
    makeWrapper $out/libexec/waydroid_script/main.py $out/bin/waydroid-script \
      --prefix PATH : ${lib.makeBinPath [lzip]}
    runHook postInstall
  '';

  meta = {
    description = "Install libndk and other extras into Waydroid";
    homepage = "https://github.com/casualsnek/waydroid_script";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "waydroid-script";
  };
}
