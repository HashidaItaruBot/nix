{
  lib,
  stdenv,
  fetchurl,
  glibc,
  makeWrapper,
}:
stdenv.mkDerivation rec {
  pname = "opencode-v2";
  version = "2.0.26";

  # nixpkgs 仅含 V1 (1.x)；V2 以平台专属 npm 包分发 Bun 单文件可执行
  src = fetchurl {
    url = "https://registry.npmjs.org/@opencode/cli-linux-x64/-/cli-linux-x64-${version}.tgz";
    hash = "sha256-ChFuAzoCgEdB1GRDN9ASvfWiSqwzo0wMllNNLVOWERk=";
  };

  # Bun 单文件可执行的载荷按绝对偏移追加在 ELF 之后：
  # autoPatchelf 撑大 PT_INTERP、strip 重写节区都会使偏移失效，
  # 二进制退化为裸 Bun。故不 patch、不 strip，改用显式 glibc ld.so 启动。
  dontStrip = true;

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/opencode $out/libexec/opencode
    makeWrapper ${glibc}/lib64/ld-linux-x86-64.so.2 $out/bin/opencode \
      --add-flags "$out/libexec/opencode"

    runHook postInstall
  '';

  meta = with lib; {
    description = "AI coding agent built for the terminal (v2)";
    homepage = "https://opencode.ai";
    license = licenses.mit;
    mainProgram = "opencode";
    platforms = ["x86_64-linux"];
  };
}
