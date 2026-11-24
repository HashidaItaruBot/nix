# packages/nipaplay/package.nix
# NipaPlay-Reload Linux desktop: a Flutter application built from source (v1.11.12).
# Replicates the upstream official Linux build (.github/actions/build-linux):
#   - Flutter 3.47 (nixpkgs-unstable flutter347, same generation as upstream's pinned 3.47.0-0.3.pre beta)
#   - libmpv from nixpkgs mpv (upstream links the system libmpv2 via pkg-config)
#   - the "Erika" native playback kernel: official prebuilt bundle from the liberika
#     v0.3.8 release. Upstream v1.11.12 replaced the xtask source build with this zip —
#     scripts/build_erika_linux_runtime.sh downloads erika-capi-linux-<arch>-bundled.zip
#     from the liberika v0.3.8 release and sha256-verifies it (x64: 269d3ef1…, matches our
#     prefetch); we mirror the same artifact. The v1.11.11-era source build, its vendored
#     third-party tarballs and .github/patches/erika-linux-native-deps.patch were deleted
#     upstream (patch is 404 at v1.11.12).
#   - the Rust FRB library librust_lib_nipaplay.so is prebuilt and injected via the official
#     NIPAPLAY_RUST_LIBRARY hook, skipping cargokit entirely (avoids network access)
#   - pub dependencies resolved offline by pub2nix (pubspec.lock.json + git-hashes.json)
{
  lib,
  callPackage,
  nixpkgsPath,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  fetchzip,
  rustPlatform,
  cmake,
  ninja,
  pkg-config,
  python3,
  autoPatchelfHook,
  wrapGAppsHook3,
  flutter347,
  gst_all_1,
  gtk3,
  mimalloc,
  keybinder3,
  libayatana-appindicator,
  libevdev,
  alsa-lib,
  libpulseaudio,
  libepoxy,
  wayland,
  libva,
  libdrm,
  sqlite,
  mpv,
  vulkan-loader,
  mdk-sdk,
}: let
  nipaplayVersion = "1.11.12";

  src = fetchFromGitHub {
    owner = "AimesSoft";
    repo = "NipaPlay-Reload";
    tag = "v${nipaplayVersion}";
    fetchSubmodules = true;
    hash = "sha256-n9C+wCSecbRIPvCxfkIErtzQzzNrwT1YGgqMD3F6cEc=";
  };

  # Official prebuilt Erika runtime (liberika v0.3.8 release). Same artifact and
  # sha256 upstream's scripts/build_erika_linux_runtime.sh verifies (zip sha256
  # 269d3ef1…; NAR hash is fetchzip's stripRoot+perm-normalized tree, taken from
  # the real fetch's got: line).
  erikaRuntime = fetchzip {
    url = "https://github.com/AimesSoft/liberika/releases/download/v0.3.8/erika-capi-linux-x64-bundled.zip";
    hash = "sha256-yxbk0N0NLtk7Rr6WBB5OcGmJKIm+B3+/irhpbqjwMFA=";
  };

  # Rust FRB library, built from the app source's rust/ tree (Cargo.lock unchanged in v1.11.12).
  librustLib = rustPlatform.buildRustPackage rec {
    pname = "librust_lib_nipaplay";
    version = nipaplayVersion;

    inherit src;
    sourceRoot = "source/rust";

    cargoDeps = rustPlatform.importCargoLock {
      lockFile = "${src}/rust/Cargo.lock";
    };

    doCheck = false;

    preBuild = ''
      # nixpkgs cargo-setup-hook.sh (nixpkgs-unstable since ~2026-11-06) now
      # exports AWS_LC_SYS_USE_SYSTEM=1 globally, forcing aws-lc-sys to link a
      # system AWS-LC. This derivation wires no system aws-lc/openssl, so the
      # pkg-config probe finds nothing and the build panics. Exporting 0 here
      # (after all hooks, before cargo invokes build scripts) restores the
      # vendored source build this package was verified with.
      export AWS_LC_SYS_USE_SYSTEM=0
    '';
  };

  # Instantiate buildFlutterApplication once so the Flutter SDK carries the web platform artifacts,
  # used for the web asset build equivalent to upstream's build_and_copy_web.
  buildFlutterApplication = callPackage "${nixpkgsPath}/pkgs/development/compilers/flutter/build-support/build-flutter-application.nix" {
    flutter = flutter347.override {
      supportedTargetFlutterPlatforms = ["universal" "linux" "web"];
    };
  };
in
  buildFlutterApplication {
    pname = "nipaplay-reload";
    version = nipaplayVersion;
    inherit src;

    pubspecLock = lib.importJSON ./pubspec.lock.json;
    gitHashes = lib.importJSON ./git-hashes.json;

    # Path dependencies resolve to the pristine fetched source (FOD): postPatch in overrideAttrs
    # never runs in fixed-output derivations -> must unpack, patch, and install via mkDerivation,
    # preserving the passthru.packageRoot semantics (isomorphic to the nixpkgs hosted builder).
    # fvp: wire the mdk dependency to nixpkgs mdk-sdk (otherwise unpacking its mdk-sdk tarball needs network)
    customSourceBuilders.fvp = {
      version,
      src,
      ...
    }:
      stdenv.mkDerivation {
        pname = "pub-fvp-src";
        inherit (src) passthru;
        inherit version;
        inherit src;
        dontBuild = true;
        postPatch = ''
          pushd "${src.passthru.packageRoot}"
          sed -i 's|.*libc++.so.1.*|${mdk-sdk}/lib/libc++.so.1|' linux/CMakeLists.txt
          substituteInPlace linux/CMakeLists.txt \
            --replace-fail "fvp_setup_deps()" "include(${mdk-sdk}/lib/cmake/FindMDK.cmake)"
          popd
        '';
        installPhase = ''
          runHook preInstall
          cp -r . "$out"
          runHook postInstall
        '';
      };

    # volume_controller: provide ALSA via pkg-config (Nix has no default system ALSA path)
    customSourceBuilders.volume_controller = {
      version,
      src,
      ...
    }:
      stdenv.mkDerivation {
        pname = "pub-volume-controller-src";
        inherit (src) passthru;
        inherit version;
        inherit src;
        dontBuild = true;
        postPatch = ''
          pushd "${src.passthru.packageRoot}"
          substituteInPlace linux/CMakeLists.txt \
            --replace-fail "# ALSA dependency for volume control" "find_package(PkgConfig REQUIRED)" \
            --replace-fail "find_package(ALSA REQUIRED)" "pkg_check_modules(ALSA REQUIRED alsa)"
          popd
        '';
        installPhase = ''
          runHook preInstall
          cp -r . "$out"
          runHook postInstall
        '';
      };

    # keep pub2nix's path relative to the root as "./" (by default it is cleared to an empty string -> becomes an absolute path starting with "/")
    packageRoot = ".";

    nativeBuildInputs = [
      autoPatchelfHook
      wrapGAppsHook3
      pkg-config
      cmake
      ninja
      python3
    ];

    buildInputs = [
      gtk3
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      mimalloc
      keybinder3
      libayatana-appindicator
      libevdev
      alsa-lib
      libpulseaudio
      libepoxy
      wayland
      libva
      libdrm
      sqlite
      mpv
    ];

    env = {
      ERIKA_LIBRARY_DIR = "${erikaRuntime}/lib";
      NIPAPLAY_RUST_LIBRARY = "${librustLib}/lib/librust_lib_nipaplay.so";
    };

    # flutter build linux invokes cmake/ninja itself according to the platform
    dontUseCmakeConfigure = true;

    # pubspec_overrides.linux.yaml is already reflected in pubspec.lock.json (linux profile);
    # enable the overrides file too, keeping semantics consistent with CI's configure step.
    # Note: path-dependency plugins build their CMake inside this source tree (ephemeral points at this tree), so
    # all patches to vendored plugins must edit this tree's files directly.
    postPatch = ''
      cp pubspec_overrides.linux.yaml pubspec_overrides.yaml
      python3 .github/workflows/scripts/generate-build-info-json.py assets/build_info.json
    '';

    flutterBuildFlags = [
      "--obfuscate"
      "--dart-define=NIPAPLAY_LINUX_ERIKA=true"
    ];

    # Fully replicate CI: build web -> copy assets -> flutter build linux --obfuscate
    buildPhase = ''
      runHook preBuild

      mkdir -p build/flutter_assets/fonts

      # web build (remote Web UI). Upstream convention: on failure, fall back to an empty assets/web and continue
      if ! flutter build web -v; then
        echo "WARNING: Flutter web build failed. Remote web UI disabled (upstream-equivalent fallback)."
      fi
      rm -rf assets/web
      mkdir -p assets/web
      if [ -d build/web ]; then
        cp -r build/web assets/web/
      fi

      flutter build linux --release --obfuscate --split-debug-info="$debug" \
        --dart-define=NIPAPLAY_LINUX_ERIKA=true

      test -f build/linux/x64/release/bundle/lib/liberika_capi.so
      mkdir -p build/linux/x64/release/bundle/lib/erika-licenses
      test -d ${erikaRuntime}/licenses && cp -a ${erikaRuntime}/licenses/. build/linux/x64/release/bundle/lib/erika-licenses/ || true
      chmod -R u+w build/linux/x64/release/bundle/lib/erika-licenses 2>/dev/null || true
      for f in ${erikaRuntime}/LICENSE ${erikaRuntime}/THIRD_PARTY_NOTICES.md ${erikaRuntime}/MANIFEST.txt; do
        test -f "$f" && cp "$f" build/linux/x64/release/bundle/lib/erika-licenses/ && chmod u+w build/linux/x64/release/bundle/lib/erika-licenses/$(basename "$f")
      done

      runHook postBuild
    '';

    # Dependency version declarations follow upstream: put the YAML pubspec.lock back (the app reads it as a pubspec.lock asset)
    postConfigure = ''
      rm -f pubspec.lock
      cp ${src}/pubspec.lock pubspec.lock
    '';

    postInstall = ''
      install -Dm644 ${src}/assets/linux/io.github.MCDFsteve.NipaPlay-Reload.desktop \
        $out/share/applications/io.github.MCDFsteve.NipaPlay-Reload.desktop
      install -Dm644 ${src}/assets/images/logo512.png \
        $out/share/icons/hicolor/512x512/apps/io.github.MCDFsteve.NipaPlay-Reload.png
      substituteInPlace $out/share/applications/io.github.MCDFsteve.NipaPlay-Reload.desktop \
        --replace-fail "Exec=/opt/nipaplay/launcher.sh %f" "Exec=$out/bin/NipaPlay %f"
    '';

    preFixup = ''
      patchelf --shrink-rpath --allowed-rpath-prefixes "$NIX_STORE" $out/app/nipaplay-reload/lib/lib*.so
    '';

    extraWrapProgramArgs = ''
      --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib:${vulkan-loader}/lib \
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${
        lib.makeSearchPath "lib/gstreamer-1.0" [
          gst_all_1.gst-plugins-base
          gst_all_1.gst-plugins-good
          gst_all_1.gst-plugins-bad
        ]
      }
    '';

    meta = {
      description = "A modern cross-platform local video player with danmaku support";
      homepage = "https://github.com/AimesSoft/NipaPlay-Reload";
      license = lib.licenses.gpl3Only;
      mainProgram = "NipaPlay";
      platforms = ["x86_64-linux"];
    };
  }
