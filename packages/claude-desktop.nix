# Claude Desktop 官方 Linux beta（Chat / Cowork / Claude Code Desktop）。
# 源为 Anthropic 官方 apt 仓库 (downloads.claude.ai)，非社区重新打包。
# 参考 github:tomsch/claude-desktop-nix (MIT)，差异：wrapper 用
# --ozone-platform-hint=auto 自动适配 X11 (KDE) 与 Wayland (Hyprland) 会话，
# 上游硬编码 --ozone-platform=wayland 在纯 X11 会话下无法连接 display。
#
# 更新版本：查 apt index 的 Version + SHA256，改下方 version/hash：
#   curl -fsSL https://downloads.claude.ai/claude-desktop/apt/stable/dists/stable/main/binary-amd64/Packages | grep -E '^(Version|SHA256):'
{
  lib,
  stdenvNoCC,
  fetchurl,
  dpkg,
  makeWrapper,
  autoPatchelfHook,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libGL,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  pipewire, # claude-native-binding.node 链接 libpipewire-0.3.so.0
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
  libxshmfence,
  systemdLibs, # libudev.so.1
  libseccomp,
  libcap_ng,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "claude-desktop";
  version = "4.4212.0";

  src = fetchurl {
    url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${finalAttrs.version}_amd64.deb";
    hash = "sha256-T89ljg/IlTkKuCWTKHKB37ziYbDsPqkAYOgti/v9eoQ=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libGL
    libxkbcommon
    mesa
    nspr
    nss
    pango
    pipewire
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    libxshmfence
    libseccomp
    libcap_ng
    systemdLibs
  ];

  dontConfigure = true;
  dontBuild = true;

  # 沙箱内 `dpkg-deb -x` 会尝试恢复 chrome-sandbox 的 setuid 位而被拒，
  # 改走 tar 流并丢弃权限/属主。
  unpackPhase = ''
    runHook preUnpack
    dpkg-deb --fsys-tarfile $src | tar --no-same-permissions --no-same-owner -x
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/bin $out/share
    cp -r usr/lib/claude-desktop $out/lib/claude-desktop
    cp -r usr/share/icons $out/share/
    cp -r usr/share/applications $out/share/

    # Chromium SUID 沙箱在 Nix store 不可用 (无法 setuid)，必须 --no-sandbox；
    # ozone-platform-hint=auto 会话自动选择 X11/Wayland；
    # wayland-ime 参数在 X11 会话下被忽略，Wayland (Hyprland) 下供 fcitx5 使用。
    makeWrapper "$out/lib/claude-desktop/claude-desktop" "$out/bin/claude-desktop" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}" \
      --add-flags "--no-sandbox" \
      --add-flags "--enable-features=UseOzonePlatform,WaylandWindowDecorations" \
      --add-flags "--ozone-platform-hint=auto" \
      --add-flags "--enable-wayland-ime" \
      --add-flags "--wayland-text-input-version=3"

    # 三条 Exec (主入口 + NewChat/NewCode actions) 都指向 wrapper
    substituteInPlace $out/share/applications/com.anthropic.Claude.desktop \
      --replace-fail "Exec=claude-desktop" "Exec=$out/bin/claude-desktop"

    runHook postInstall
  '';

  meta = {
    description = "Claude Desktop App (official Linux beta)";
    homepage = "https://claude.com/download";
    license = lib.licenses.unfree;
    platforms = ["x86_64-linux"];
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    mainProgram = "claude-desktop";
  };
})
