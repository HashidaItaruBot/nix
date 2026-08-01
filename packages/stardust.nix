{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    stardust-xr-server # XR 核心服务
    stardust-xr-flatland # 在 VR 中运行 2D Linux 应用
    stardust-xr-gravity # 应用启动器和窗口布局
    stardust-xr-atmosphere # 环境/天空盒
    stardust-xr-protostar # 交互式 3D UI
    stardust-xr-non-spatial-input # 输入处理
  ];
}
