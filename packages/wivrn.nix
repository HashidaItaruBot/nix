{
  pkgs,
  ...
}: let
  # WiVRn config 的 application 会被拼成单个字符串，用包装脚本带参数更稳妥
  wayvr-autostart = pkgs.writeShellApplication {
    name = "wayvr-autostart";
    runtimeInputs = [pkgs.wayvr];
    text = ''
      exec wayvr --openxr --show --wait "$@"
    '';
  };
in {
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
