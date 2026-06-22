{
  pkgs,
  lib,
  ...
}:
let
  mainMod = "SUPER";
  terminal = "ghostty"; # 修复拼写：原 "ghotty"
  fileManager = "dolphin";
  menu = "fuzzel"; # 替换未安装的 hyprlauncher

  # 截图保存目录
  screenshotDir = "$HOME/Pictures/Screenshots";
  recordingDir = "$HOME/Videos/recordings";

  # 工作区 1-10 的按键绑定 (i=10 映射到按键 0)
  workspaceKey = i: if i == 10 then "0" else toString i;
  workspaceBinds =
    (map (i: "${mainMod}, ${workspaceKey i}, workspace, ${toString i}") (lib.range 1 10))
    ++ (map (i: "${mainMod} SHIFT, ${workspaceKey i}, movetoworkspace, ${toString i}") (
      lib.range 1 10
    ));
in
{
  wayland.windowManager.hyprland.settings = {
    # ---- 按键绑定 ----
    bind =
      [
        "${mainMod}, Q, exec, ${terminal}"
        "${mainMod}, C, killactive"
        "${mainMod}, M, exec, command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"
        "${mainMod}, E, exec, ${fileManager}"
        "${mainMod}, V, togglefloating"
        "${mainMod}, R, exec, ${menu}"
        "${mainMod}, P, pseudo"
        "${mainMod}, J, togglesplit"

        # 方向键移动焦点
        "${mainMod}, left, movefocus, l"
        "${mainMod}, right, movefocus, r"
        "${mainMod}, up, movefocus, u"
        "${mainMod}, down, movefocus, d"

        # 特殊工作区 (scratchpad)
        "${mainMod}, S, togglespecialworkspace, magic"
        "${mainMod} SHIFT, S, movetoworkspace, special:magic"

        # 滚轮切换工作区
        "${mainMod}, mouse_down, workspace, e+1"
        "${mainMod}, mouse_up, workspace, e-1"

        # ---- 锁屏 ----
        # Plasma kscreenlocker 在 Hyprland 会话下不生效，用 hyprlock 替代
        "${mainMod}, L, exec, hyprlock"
        # 关屏不锁（临时离开）
        "${mainMod} SHIFT, L, exec, hyprctl dispatch dpms off"

        # ---- 截图 ----
        # 截图到剪贴板
        "${mainMod} SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy"
        # 截图到文件
        "${mainMod} SHIFT, P, exec, mkdir -p ${screenshotDir} && grim -g \"$(slurp)\" ${screenshotDir}/$(date +%Y%m%d-%H%M%S).png"

        # ---- 屏幕录制 ----
        "${mainMod} SHIFT, V, exec, mkdir -p ${recordingDir} && wf-recorder -g \"$(slurp)\" -f ${recordingDir}/$(date +%Y%m%d-%H%M%S).mp4"

        # ---- Resize submap ----
        # 进入 resize 子模式（避开 SUPER+R 启动器）
        "${mainMod} SHIFT, R, submap, resize"
      ]
      ++ workspaceBinds;

    # 鼠标绑定
    bindm = [
      "${mainMod}, mouse:272, movewindow"
      "${mainMod}, mouse:273, resizewindow"
    ];

    # 多媒体按键 (带重复)
    binde = [
      ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ", XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
      ", XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
    ];

    # 媒体控制按键 (锁定)
    bindl = [
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
    ];

    # ---- Submap: resize ----
    # Hyprland submap 配置：每个元素是一行 hyprlang 配置
    # 通过 "submap = <name>" 开启块，"submap = reset" 结束
    submap = [
      "resize"
      "bind = , h, resizeactive, -10 0"
      "bind = , l, resizeactive, 10 0"
      "bind = , k, resizeactive, 0 -10"
      "bind = , j, resizeactive, 0 10"
      "bind = , left, resizeactive, -10 0"
      "bind = , right, resizeactive, 10 0"
      "bind = , up, resizeactive, 0 -10"
      "bind = , down, resizeactive, 0 10"
      "bind = , escape, submap, reset"
      "bind = ${mainMod} SHIFT, R, submap, reset"
      "submap = reset"
    ];
  };
}
