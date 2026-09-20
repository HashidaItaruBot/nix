{pkgs, ...}: {
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
