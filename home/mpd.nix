# MPD 守护进程 + Cantata 前端
# MPD 以用户服务运行 (systemd --user)，通过 PipeWire 输出音频
{pkgs, ...}: {
  services.mpd = {
    enable = true;
    musicDirectory = "/home/zhaochanglong/Music";
    network.listenAddress = "127.0.0.1";
    network.startWhenNeeded = true;
    extraConfig = ''
      audio_output {
        type "pulse"
        name "PipeWire Output"
      }

      # 音频缓冲，单位秒；适当加大防止卡顿
      audio_buffer_size "4096"
      buffer_before_play "20%"

      # 重采样使用 soxr 高质量算法（播放普通 CD 音源时才会生效）
      samplerate_converter "soxr"
    '';
  };

  home.packages = with pkgs; [
    mpc # 命令行控制
    cantata # MPD 图形前端
  ];
}
