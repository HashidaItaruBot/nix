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
  version = "0-unstable-2026-11-14";

  src = fetchFromGitHub {
    owner = "casualsnek";
    repo = "waydroid_script";
    rev = "4a50dabd97fcb632a608b1421105258862a5b994";
    hash = "sha256-J6IMebq5WLRXHi9zV7wWX91JQkVVKevE1NfRm84Iids=";
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
