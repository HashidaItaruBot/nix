{pkgs}:
pkgs.writeShellApplication {
  name = "baidunetdisk-sandbox";
  runtimeInputs = with pkgs; [
    bubblewrap
    coreutils
    xdg-dbus-proxy
  ];

  text = ''
    set -euo pipefail

    appimage="''${BAIDUNETDISK_APPIMAGE:-$HOME/Applications/BaiduNetdisk.AppImage}"
    sandbox_root="$HOME/.local/share/baidunetdisk-sandbox"
    sandbox_home="$sandbox_root/home"
    runtime_dir="''${XDG_RUNTIME_DIR:-/run/user/$UID}"

    if [ ! -x "$appimage" ]; then
      printf '百度网盘 AppImage 不存在或不可执行: %s\n' "$appimage" >&2
      printf '请将文件放到 ~/Applications/BaiduNetdisk.AppImage，或设置 BAIDUNETDISK_APPIMAGE。\n' >&2
      exit 1
    fi

    mkdir -p "$sandbox_home" "$HOME/Downloads"

    bwrap_args=(
      --die-with-parent
      --new-session
      --unshare-pid
      --unshare-uts
      --clearenv
      --ro-bind /nix/store /nix/store
      --ro-bind /run/current-system /run/current-system
      --ro-bind /etc /etc
      --ro-bind /usr /usr
      --ro-bind /bin /bin
      --dev /dev
      --proc /proc
      --tmpfs /tmp
      --dir /home
      --bind "$sandbox_home" "/home/$USER"
      --bind "$HOME/Downloads" "/home/$USER/Downloads"
      --ro-bind "$appimage" /opt/BaiduNetdisk.AppImage
      --setenv HOME "/home/$USER"
      --setenv USER "$USER"
      --setenv LOGNAME "$USER"
      --setenv PATH "/run/current-system/sw/bin:/bin:/usr/bin"
      --setenv LANG "''${LANG:-C.UTF-8}"
      --setenv XDG_CURRENT_DESKTOP "''${XDG_CURRENT_DESKTOP:-KDE}"
      --setenv XDG_RUNTIME_DIR "/run/user/$UID"
    )

    if [ -d "$runtime_dir" ]; then
      bwrap_args+=(--dir /run --dir /run/user --dir "/run/user/$UID")
    fi

    if [ -n "''${WAYLAND_DISPLAY:-}" ] && [ -S "$runtime_dir/$WAYLAND_DISPLAY" ]; then
      bwrap_args+=(
        --bind "$runtime_dir/$WAYLAND_DISPLAY" "/run/user/$UID/$WAYLAND_DISPLAY"
        --setenv WAYLAND_DISPLAY "$WAYLAND_DISPLAY"
      )
    fi

    if [ -n "''${DISPLAY:-}" ] && [ -d /tmp/.X11-unix ]; then
      bwrap_args+=(--ro-bind /tmp/.X11-unix /tmp/.X11-unix --setenv DISPLAY "$DISPLAY")
    fi

    if [ -n "''${XAUTHORITY:-}" ] && [ -f "$XAUTHORITY" ]; then
      bwrap_args+=(
        --ro-bind "$XAUTHORITY" /tmp/.Xauthority
        --setenv XAUTHORITY /tmp/.Xauthority
      )
    fi

    if [ -S "$runtime_dir/bus" ]; then
      dbus_proxy="$sandbox_root/dbus-proxy"
      rm -f "$dbus_proxy"
      xdg-dbus-proxy \
        "unix:path=$runtime_dir/bus" \
        "$dbus_proxy" \
        --filter \
        --talk=org.freedesktop.portal.Desktop \
        --talk=org.freedesktop.portal.Documents \
        --talk=org.kde.StatusNotifierWatcher &
      dbus_proxy_pid=$!
      trap 'kill "$dbus_proxy_pid" 2>/dev/null || true; rm -f "$dbus_proxy"' EXIT

      for _ in $(seq 1 20); do
        [ -S "$dbus_proxy" ] && break
        sleep 0.05
      done
      if [ ! -S "$dbus_proxy" ]; then
        printf '无法启动百度网盘的 D-Bus 代理。\n' >&2
        exit 1
      fi

      bwrap_args+=(
        --bind "$dbus_proxy" "/run/user/$UID/bus"
        --setenv DBUS_SESSION_BUS_ADDRESS "unix:path=/run/user/$UID/bus"
      )
    fi

    if [ -S "$runtime_dir/pipewire-0" ]; then
      bwrap_args+=(--bind "$runtime_dir/pipewire-0" "/run/user/$UID/pipewire-0")
    fi

    if [ -S "$runtime_dir/pulse/native" ]; then
      bwrap_args+=(
        --bind "$runtime_dir/pulse/native" "/run/user/$UID/pulse/native"
        --setenv PULSE_SERVER "unix:/run/user/$UID/pulse/native"
      )
    fi

    exec bwrap "''${bwrap_args[@]}" -- /opt/BaiduNetdisk.AppImage --appimage-extract-and-run "$@"
  '';
}
