# WayVR：4K 桌面镜像清晰度调优
# zzz- 前缀保证覆盖 Dashboard 写入的 zz-saved-config.json5
{pkgs, ...}: {
  xdg.configFile."wayvr/conf.d/zzz-sharp.yaml".text = ''
    # 4K 监视器镜像时降采样，减少锯齿与 WiVRn 压缩糊字
    screen_render_down: true
    screen_max_height: 1440
  '';

  # Steam/OpenVR 通过此文件找 runtime；必须指向当前 xrizer（含 IVRSystem_026）
  xdg.configFile."openvr/openvrpaths.vrpath".text = builtins.toJSON {
    runtime = ["${pkgs.xrizer}/lib/xrizer"];
    version = 1;
  };
}
