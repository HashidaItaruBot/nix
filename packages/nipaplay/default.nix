# packages/nipaplay/package.nix
# NipaPlay-Reload Linux 桌面版：从源码构建的 Flutter 应用 (v1.11.9)。
# 复刻上游官方 Linux 构建 (.github/workflows/build-linux.yml):
#   - Flutter 3.47 (nixpkgs-unstable flutter347, 上游 pin 3.47.0-0.3.pre beta 同代)
#   - libmpv 走 nixpkgs mpv (上游 link 系统 libmpv2，pkg-config 链接)
#   - "Erika" 原生播放内核 (AimesSoft/liberika v0.2.1)：xtask 离线编译 vendored
#     FFmpeg 8.1.2 / dav1d / libass / harfbuzz / freetype / fribidi / zlib
#   - Rust FRB 库 librust_lib_nipaplay.so 预编译并经官方
#     NIPAPLAY_RUST_LIBRARY 钩子注入，完全跳过 cargokit (避免联网)
#   - pub 依赖由 pub2nix 离线解析 (pubspec.lock.json + git-hashes.json)
{
  lib,
  callPackage,
  nixpkgsPath,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  fetchgit,
  rustPlatform,
  cargo,
  rustc,
  cmake,
  ninja,
  meson,
  nasm,
  yasm,
  pkg-config,
  python3,
  zip,
  unzip,
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
  llvmPackages,
  mdk-sdk,
  zlib,
}: let
  nipaplayVersion = "1.11.10";

  src = fetchFromGitHub {
    owner = "AimesSoft";
    repo = "NipaPlay-Reload";
    tag = "v${nipaplayVersion}";
    fetchSubmodules = true;
    hash = "sha256-g86p34N96VbwogPXq6oHtCn4RQZf3vV3GjixeA7Xdd4=";
  };

  # NipaPlay 仓库内针对 liberika v0.2.1 的 Linux 构建补丁。
  erikaPatch = fetchurl {
    url = "https://raw.githubusercontent.com/AimesSoft/NipaPlay-Reload/v${nipaplayVersion}/.github/patches/erika-linux-native-deps.patch";
    hash = "sha256:0as7cd9vb800wnsgyk6x26acn5vzh7z9j8a14v3g0gjzi76rv4xs";
  };

  # liberika xtask 的 vendored 第三方源码档：预填 third_party/cache 后
  # xtask 全程离线，从这些归档解包并编译 (third_party/src 也会一致生成)。
  ffmpegTarball = fetchurl {
    url = "https://codeload.github.com/FFmpeg/FFmpeg/tar.gz/refs/tags/n8.1.2";
    hash = "sha256:1dvfazh8ppvjhcjy31kk5z8k83z4v4w6vslmw2pypfq52r8r5l4z";
  };
  dav1dTarball = fetchurl {
    url = "https://codeload.github.com/videolan/dav1d/tar.gz/refs/tags/1.5.1";
    hash = "sha256:15dnfjfwny8mzi9rlfxvhaamhk74bphq6z00hh9pn515vcmmwqzs";
  };
  libassTarball = fetchurl {
    url = "https://github.com/libass/libass/releases/download/0.17.5/libass-0.17.5.tar.xz";
    hash = "sha256:1k2ahs42433bh0kq40ddsgfy9hfah8zin0aj1gqdsdy8w302bjid";
  };
  harfbuzzTarball = fetchurl {
    url = "https://github.com/harfbuzz/harfbuzz/releases/download/14.2.1/harfbuzz-14.2.1.tar.xz";
    hash = "sha256:03ifj1bmlv58phdkznd0zhnpj13ppyy6gqrcfsxiz940jf75sjm5";
  };
  freetypeTarball = fetchurl {
    url = "https://codeload.github.com/freetype/freetype/tar.gz/refs/tags/VER-2-14-3";
    hash = "sha256:0qb2nl57dyyj7gvfzwlgwb9pbi22k16x6kbahzsfwrm205mxwjfw";
  };
  fribidiTarball = fetchurl {
    url = "https://github.com/fribidi/fribidi/releases/download/v1.0.16/fribidi-1.0.16.tar.xz";
    hash = "sha256:0p50krd2mn244y5fqw5li9623qq9lf40wbxyj6g4fh2x4ddxw70v";
  };
  zlibTarball = fetchurl {
    url = "https://codeload.github.com/madler/zlib/tar.gz/refs/tags/v1.3.2";
    hash = "sha256:18cmljadc32whgva13vcjgkg3g8w7gjg3i3qgvn614xsq230p6mr";
  };
  nvCodecHeadersTarball = fetchurl {
    url = "https://codeload.github.com/FFmpeg/nv-codec-headers/tar.gz/refs/tags/n13.0.19.0";
    hash = "sha256:05h1jhi1rnyqyhf57gwm8lkahzdszvmppifzmw73miqaghd5vlc6";
  };
  vulkanHeadersTarball = fetchurl {
    url = "https://codeload.github.com/KhronosGroup/Vulkan-Headers/tar.gz/refs/tags/v1.3.290";
    hash = "sha256:1xdwx6yqah652ggagh7434l9mfhw7gax4lws48m7marwz4xnb2pk";
  };

  librustLib = rustPlatform.buildRustPackage rec {
    pname = "librust_lib_nipaplay";
    version = nipaplayVersion;

    inherit src;
    sourceRoot = "source/rust";

    cargoDeps = rustPlatform.importCargoLock {
      lockFile = "${src}/rust/Cargo.lock";
    };

    doCheck = false;
  };

  erikaRuntime = stdenv.mkDerivation rec {
    pname = "liberika-runtime";
    version = "0.2.1";

    src = fetchgit {
      url = "https://github.com/AimesSoft/Erika";
      rev = "70f12bf325ce8d020d2155635f5992eff4654321";
      hash = "sha256-FKUAwOe06XFh1F5FYws5ekJZw9cYc5PEj30KMgrfgfA=";
    };

    cargoDeps = rustPlatform.importCargoLock {
      lockFile = "${src}/Cargo.lock";
    };

    nativeBuildInputs = [
      rustPlatform.cargoSetupHook
      cargo
      rustc
      cmake
      meson
      ninja
      llvmPackages.clang
      nasm
      yasm
      pkg-config
      python3
      zip
      unzip
    ];

    buildInputs = [
      libva
      libdrm
      libpulseaudio
      vulkan-loader
      zlib
    ];

    LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
    BINDGEN_EXTRA_CLANG_ARGS = "-I${llvmPackages.libclang.lib}/lib/clang/${llvmPackages.llvm.version}/include";
    # ffmpeg 参数 --enable-libdrm/vaapi/vulkan/zlib 走 pkg-config，显式给 pc 路径
    PKG_CONFIG_PATH = lib.strings.concatStringsSep ":" [
      "${lib.getDev libdrm}/lib/pkgconfig"
      "${lib.getDev libva}/lib/pkgconfig"
      "${lib.getDev vulkan-loader}/lib/pkgconfig"
      "${lib.getDev zlib}/lib/pkgconfig"
    ];

    # Erika 非手写 CMake 工程；vendored 依赖由 xtask 自行调用 cmake/meson
    dontUseCmakeConfigure = true;
    dontUseMesonConfigure = true;

    hardeningDisable = ["fortify"];

    prePatch = ''
      patch -p1 < ${erikaPatch}

      # CMake GNUInstallDirs 在此环境选 lib64，xtask 只认 lib/pkgconfig：
      # 在 freetype build 调用处固定 CMAKE_INSTALL_LIBDIR=lib
      sed -i 's|\.arg("-DFT_DISABLE_ZLIB=TRUE")|.arg("-DCMAKE_INSTALL_LIBDIR=lib") .arg("-DFT_DISABLE_ZLIB=TRUE")|' xtask/src/main.rs
      sed -i 's|\.arg("-DHB_BUILD_UTILS=OFF")|.arg("-DCMAKE_INSTALL_LIBDIR=lib") .arg("-DHB_BUILD_UTILS=OFF")|' xtask/src/main.rs
      sed -i 's|\.arg("-DZLIB_INSTALL=ON")|.arg("-DCMAKE_INSTALL_LIBDIR=lib") .arg("-DZLIB_INSTALL=ON")|' xtask/src/main.rs

      # 预填 xtask 归档缓存 (third_party/cache) —— xtask 由此全程离线
      mkdir -p third_party/cache
      cp ${ffmpegTarball} third_party/cache/ffmpeg-n8.1.2.tar.gz
      cp ${dav1dTarball} third_party/cache/dav1d-1.5.1.tar.gz
      cp ${libassTarball} third_party/cache/libass-0.17.5.tar.xz
      cp ${harfbuzzTarball} third_party/cache/harfbuzz-14.2.1.tar.xz
      cp ${freetypeTarball} third_party/cache/freetype-VER-2-14-3.tar.gz
      cp ${fribidiTarball} third_party/cache/fribidi-1.0.16.tar.xz
      cp ${zlibTarball} third_party/cache/zlib-1.3.2.tar.gz
    '';

    buildPhase = ''
      runHook preBuild

      # nv-codec-headers (FFmpeg NVENC/NVDEC 声明) → 自建 pkgconfig 前缀，
      # 并把 nixpkgs 的 libdrm/libva/vulkan pc 目录一并交给 xtask：
      # 补丁把 ffmpeg 配置子进程的 PKG_CONFIG_PATH 重置为
      # <dav1d dist>:<ERIKA_LINUX_PKG_CONFIG_DIRS>，CI 在 Ubuntu 上靠系统
      # pc 路径找到 libdrm 等；Nix 下该变量必须显式指向 nixpkgs 头目录
      setupPrefix=$(mktemp -d)
      tar xf ${nvCodecHeadersTarball} -C "$setupPrefix" --strip-components=1
      make -C "$setupPrefix" install PREFIX="$setupPrefix/nvcodec"

      # Vulkan-Headers: FFmpeg 8 的 vulkan 声明比系统头新
      mkdir -p "$setupPrefix/vulkan/include"
      tar xf ${vulkanHeadersTarball} -C "$setupPrefix/vulkan" --strip-components=1

      export ERIKA_LINUX_PKG_CONFIG_DIRS="$setupPrefix/nvcodec/lib/pkgconfig:${lib.makeSearchPathOutput "dev" "lib/pkgconfig" [libdrm libva vulkan-loader zlib]}"
      export CPATH="$setupPrefix/vulkan/include''${CPATH:+:$CPATH}"
      export ERIKA_USE_SYSTEM_LIBS=0
      export CFLAGS="''\${CFLAGS:-} -fPIC"
      export CXXFLAGS="''\${CXXFLAGS:-} -fPIC"
      export CARGO_TARGET_DIR="$PWD/target"
      export ERIKA_BUILD_JOBS="$NIX_BUILD_CORES"

      cargo run --locked -p xtask -- deps build --all --profile lgpl
      cargo rustc --locked --release -p erika_capi --lib -- \
        -C link-arg=-Wl,-soname,liberika_capi.so \
        -C link-arg=-Wl,-z,defs \
        -C link-arg=-lva -C link-arg=-lva-drm -C link-arg=-lva-x11 \
        -C link-arg=-ldrm -C link-arg=-ldl -C link-arg=-lm

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      # 复用 liberika 自带的打包脚本 (纯本地 staging，含全部 licenses)
      GITHUB_SHA="70f12bf325ce8d020d2155635f5992eff4654321" \
        GITHUB_REF_NAME="v${version}" ERIKA_NATIVE_PROFILE=lgpl \
        bash packaging/bundle.sh erika-linux ./erika-linux.zip \
        target/release/liberika_capi.so
      unzip -q erika-linux.zip -d bundle
      mkdir -p $out
      cp -a bundle/erika-linux/. $out/

      # 上游脚本 (scripts/build_erika_linux_runtime.sh) 追加的许可文件
      cp -a third_party/src/fribidi-1.0.16/COPYING $out/licenses/LICENSE.FriBidi
      cp -a third_party/build/licenses/Vulkan-Headers $out/licenses/Vulkan-Headers || true
      cp -a third_party/build/erika-linux/licenses/LICENSE.nv-codec-headers $out/licenses/LICENSE.nv-codec-headers 2>/dev/null || true

      test -f $out/lib/liberika_capi.so

      runHook postInstall
    '';

    meta = {
      description = "Erika native playback engine runtime for NipaPlay";
      homepage = "https://github.com/AimesSoft/Erika";
      license = lib.licenses.mpl20;
    };
  };

  # 自建一次 buildFlutterApplication，使 Flutter SDK 带上 web 平台 artifacts，
  # 供上游 build_and_copy_web 等价的 web 资产构建使用。
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

    # 路径依赖解析到 pristine fetched source (FOD)：overrideAttrs 的 postPatch
    # 在 fixed-output 派生里并不执行 → 必须 mkDerivation 解包修补再安装，
    # 保留 passthru.packageRoot 语义（与 nixpkgs hosted builder 同构）。
    # fvp: mdk 依赖对接 nixpkgs mdk-sdk（否则其解压 mdk-sdk tarball 需联网）
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

    # volume_controller: ALSA 改由 pkg-config 提供（Nix 无默认系统 ALSA 路径）
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

    # 让 pub2nix 的 path 相对根保持 "./" (默认会被清成空串 → 绝对路径 "/" 开头)
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

    # flutter build linux 内部自行根据平台调用 cmake/ninja
    dontUseCmakeConfigure = true;

    # pubspec_overrides.linux.yaml 已反映在 pubspec.lock.json (linux profile)；
    # 同步启用 overrides 文件，保持与 CI 的 configure 步骤语义一致。
    # 注意：路径依赖插件的 CMake 在本源码树内编译（ephemeral 指向本树），所有
    # 对 vendored 插件的修补都要直接改本树文件。
    postPatch = ''
      cp pubspec_overrides.linux.yaml pubspec_overrides.yaml
      python3 .github/workflows/scripts/generate-build-info-json.py assets/build_info.json
    '';

    flutterBuildFlags = [
      "--obfuscate"
      "--dart-define=NIPAPLAY_LINUX_ERIKA=true"
    ];

    # 完整复刻 CI: build web → 拷贝资产 → flutter build linux --obfuscate
    buildPhase = ''
      runHook preBuild

      mkdir -p build/flutter_assets/fonts

      # web 构建 (远程 Web UI)。按上游约定: 失败时降级为空 assets/web 继续
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

    # 依赖版本声明按上游: 把 YAML pubspec.lock 放回 (应用以 pubspec.lock 资产读取)
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
