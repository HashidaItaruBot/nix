# WayVR：4K 桌面镜像清晰度调优
# zzz- 前缀保证覆盖 Dashboard 写入的 zz-saved-config.json5
{
  xdg.configFile."wayvr/conf.d/zzz-sharp.yaml".text = ''
    # 4K 监视器镜像时降采样，减少锯齿与 WiVRn 压缩糊字
    screen_render_down: true
    screen_max_height: 1440
  '';
}
