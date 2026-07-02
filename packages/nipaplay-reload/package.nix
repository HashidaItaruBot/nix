{
  lib,
  lua,
  fetchFromGitHub,
  flutter,
  stdenv,
  pkg-config,
  cmake,
  ninja,
  clang,
  gtk3,
  glib,
  mpv,
  mdk-sdk,
  keybinder3,
  libplacebo,
  libunwind,
  shaderc,
  lcms2,
  libdovi,
  libdvdnav,
  libdvdread,
  libdvdcss,
  libbluray,
  mujs,
  mimalloc,
  ffmpeg,
  libass,
  pango,
  gdk-pixbuf,
  alsa-lib,
  libsecret,
  gsettings-desktop-schemas,
  libsoup_3,
  webkitgtk_4_1,
  libx11,
  at-spi2-core,
  dbus,
  wrapGAppsHook4,
  makeWrapper,
  rubberband,
  libuchardet,
  zimg,
  openal,
  pipewire,
  libpulseaudio,
  libcaca,
  libdrm,
  libepoxy,
  libglvnd,
  libdisplay-info,
  libgbm,
  libxscrnsaver,
  libayatana-appindicator,
  libxpresent,
  nv-codec-headers,
  libva,
  libvdpau,
  sqlite,
  ...
}: let
  version = "1.10.10";
in
  flutter.buildFlutterApplication {
    inherit version;
    pname = "nipaplay-reload";

    src = fetchFromGitHub {
      owner = "AimesSoft";
      repo = "NipaPlay-Reload";
      rev = "v${version}";
      hash = "sha256-4k/UWTCfYFQoFZhZu5SwuEgGD2xE6uS/cQrIR+PdkN8=";
      fetchSubmodules = true;
    };

    pubspecLock = let
      raw = lib.importJSON ./pubspec.lock.json;
    in
      raw
      // {
        packages = builtins.removeAttrs raw.packages ["rust_lib_nipaplay"];
      };

    gitHashes = {
      "erika_flutter" = "sha256-mjdn/A072ol0IWsdwahXYpv7ko2YZcKeHKvkINIfR68=";
    };

    # The nixpkgs volume_controller custom source builder does not pushd into
    # the packageRoot when it's a path dependency, so we override it here.
    customSourceBuilders = {
      volume_controller = {
        version,
        src,
        ...
      }:
        stdenv.mkDerivation {
          pname = "volume_controller";
          inherit version src;
          inherit (src) passthru;
          postPatch = lib.optionalString (lib.versionAtLeast version "3.4.0") ''
            pushd ${src.passthru.packageRoot}
            substituteInPlace linux/CMakeLists.txt \
              --replace-fail "# ALSA dependency for volume control" "find_package(PkgConfig REQUIRED)" \
              --replace-fail "find_package(ALSA REQUIRED)" "pkg_check_modules(ALSA REQUIRED alsa)"
            popd
          '';
          installPhase = ''
            runHook preInstall
            cp -r . $out
            runHook postInstall
          '';
        };
    };

    packageRoot = ".";

    dontUseCmakeConfigure = true;

    nativeBuildInputs = [
      pkg-config
      cmake
      ninja
      clang
      wrapGAppsHook4
      makeWrapper
    ];

    buildInputs = [
      gtk3
      glib
      mpv
      mdk-sdk
      keybinder3
      libunwind
      shaderc
      lcms2
      libplacebo
      libdovi
      libdvdnav
      libdvdread
      libdvdcss
      libbluray
      mujs
      mimalloc
      ffmpeg
      libass
      pango
      gdk-pixbuf
      alsa-lib
      libsecret
      libsoup_3
      webkitgtk_4_1
      libx11
      at-spi2-core
      dbus
      lua
      rubberband
      libuchardet
      zimg
      openal
      pipewire
      libpulseaudio
      libcaca
      libdrm
      libepoxy
      libglvnd
      libdisplay-info
      libgbm
      libxscrnsaver
      libayatana-appindicator
      libxpresent
      nv-codec-headers
      libva
      libvdpau
      sqlite
      gsettings-desktop-schemas
    ];

    # Skip rust_lib_nipaplay plugin (requires flutter_rust_bridge codegen + cargo build
    # in sandbox). Remove it from pubspec.yaml so Flutter tooling excludes it.
    postPatch = ''
      sed -i '/rust_lib_nipaplay:/,+1d' pubspec.yaml
      sed -i '/rust_lib_nipaplay/d' .dart_tool/package_config.json 2>/dev/null || true

      # MDK player may have EGL texture sharing issues on AMD/Wayland.
      # Force MediaKit (libmpv-based) as default, and migrate saved MDK preference.
      sed -i '
        s/_cachedKernelType = PlayerKernelType.mdk;/_cachedKernelType = PlayerKernelType.mediaKit;/g
        /PlayerKernelType.values\[kernelTypeIndex\]/c\
        _cachedKernelType = PlayerKernelType.values[kernelTypeIndex] == PlayerKernelType.mdk ? PlayerKernelType.mediaKit : PlayerKernelType.values[kernelTypeIndex];
      ' lib/player_abstraction/player_factory.dart

      # Fix: media_kit creates a GLES 2.0 EGL context but tells mpv to use
      # MPV_RENDER_API_TYPE_OPENGL (desktop GL). Mesa AMD driver reports
      # desktop GL version string for GLES contexts, so mpv uses desktop GLSL
      # shaders that fail to compile on the GLES shader compiler (blue screen).
      # Force mpv to detect GLES by setting gl-version option before render
      # context creation.
      sed -i '/mpv_set_option_string(self->handle, "video-sync", "audio");/a\  mpv_set_option_string(self->handle, "gl-version", "OpenGL ES 2.0");' \
        third_party/media-kit-upstream/media_kit_video/linux/video_output.cc
    '';

    preBuild = ''
      mkdir -p assets/web
    '';

    postInstall = ''
      install -Dm644 assets/linux/io.github.MCDFsteve.NipaPlay-Reload.desktop \
        $out/share/applications/io.github.MCDFsteve.NipaPlay-Reload.desktop
      install -Dm644 assets/images/logo512.png \
        $out/share/icons/hicolor/512x512/apps/io.github.MCDFsteve.NipaPlay-Reload.png

      # Create a wrapper script for the executable with library paths
      makeWrapper $out/app/nipaplay-reload/NipaPlay $out/bin/nipaplay-reload \
        --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          mpv
          ffmpeg
          libass
          webkitgtk_4_1
        ]
      }

      substituteInPlace $out/share/applications/io.github.MCDFsteve.NipaPlay-Reload.desktop \
        --replace "Exec=/opt/nipaplay/NipaPlay" "Exec=nipaplay-reload"
    '';

    meta = with lib; {
      description = "A modern, cross-platform local video player that supports bullet comments and multiple subtitle formats.";
      homepage = "https://github.com/AimesSoft/NipaPlay-Reload";
      changelog = "https://github.com/AimesSoft/NipaPlay-Reload/releases/tag/v${version}";
      license = licenses.mit;
      mainProgram = "nipaplay-reload";
      platforms = [
        "x86_64-linux"
      ];
      maintainers = [];
    };
  }
