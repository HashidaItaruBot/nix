{pkgs, ...}: let
  # WiVRn config 的 application 会被拼成单个字符串，用包装脚本带参数更稳妥
  wayvr-autostart = pkgs.writeShellApplication {
    name = "wayvr-autostart";
    runtimeInputs = [pkgs.wayvr];
    text = ''
      exec wayvr --openxr --show --wait "$@"
    '';
  };
in {
  # nixpkgs 的 xrizer 0.5 缺少 IVRSystem_026（NMS 更新到 OpenVR 2.15.6 后需要）。
  # 上游 #341 已合入 main，但尚未发版；钉到含该修复的 commit。
  nixpkgs.overlays = [
    (final: prev: {
      xrizer = prev.xrizer.overrideAttrs (old: let
        version = "0.5-unstable-2026-09-03";
        src = final.fetchFromGitHub {
          owner = "Supreeeme";
          repo = "xrizer";
          rev = "0989a7fac2d1efb7ea82f5fe1a8ed30c3eeb9596";
          hash = "sha256-Rb1pssAq6Zx6VmQVQtGcThkA6zCwi5X7G7aHmdsDrJo=";
        };
        cargoHash = "sha256-JKQUrHGqnU5453iVKXnO51nX2NqcBYzsfvuu92WhLDE=";
      in {
        inherit version src cargoHash;
        # finalAttrs 包的 cargoDeps 不会随 cargoHash override 自动重建
        cargoDeps = final.rustPlatform.fetchCargoVendor {
          inherit src;
          name = "xrizer-${version}";
          hash = cargoHash;
        };
        # 新 Cargo.toml 已无 static/linked 切换；仅保留 libGLX 路径替换
        postPatch = ''
          substituteInPlace src/graphics_backends/gl.rs \
            --replace-fail 'libGLX.so.0' '${final.lib.getLib final.libGL}/lib/libGLX.so.0'
        '';
        # 无 git checkout 时用显式版本，避免 vergen-gitcl 失败
        env =
          (old.env or {})
          // {
            XRIZER_VERSION = "0.5-unstable-0989a7f";
          };
      });
    })
  ];

  # WiVRn — OpenXR 无线串流（Quest 等一体机）
  services.wivrn = {
    enable = true;
    autoStart = true; # 登录时自动启动
    openFirewall = true; # 自动打开 9757 端口
    highPriority = true; # 异步重投影需要 cap_sys_nice
    monadoEnvironment = {
      IPC_EXIT_ON_DISCONNECT = "off";
      XRT_COMPOSITOR_LOG = "debug";
      XRT_PRINT_OPTIONS = "on";
    };
    steam = {
      enable = true;
      importOXRRuntimes = true; # 系统级设置 PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
    };
    # 连接头显后自动拉起 WayVR；H.265/10-bit 减轻文字糊与色带
    config = {
      enable = true;
      json = {
        bit-depth = 10;
        encoder = {
          encoder = "vaapi";
          codec = "h265";
        };
        application = [wayvr-autostart];
      };
    };
  };

  # Monado — OpenXR 运行时（xrizer 回退 + 本地 VR 应用支持）
  services.monado = {
    enable = true;
    defaultRuntime = true; # 设为系统默认 OpenXR 运行时
    highPriority = true;
  };

  # OpenVR→OpenXR 桥接 + Wayland VR compositor
  environment.systemPackages = with pkgs; [
    xrizer
    wayvr
  ];
}
