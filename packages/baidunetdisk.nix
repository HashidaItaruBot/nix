{
  lib,
  pkgs,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
}: let
  version = "4.17.8";

  runtimeLibraries = with pkgs; [
    alsa-lib
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libgbm
    libGL
    libnotify
    libsecret
    libuuid
    libxkbcommon
    libX11
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXScrnSaver
    libXtst
    mesa
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    systemd
    xdg-utils
    zlib
  ];

  payload = stdenv.mkDerivation {
    pname = "baidunetdisk-payload";
    inherit version;

    src = fetchurl {
      url = "https://issuecdn.baidupcs.com/issue/netdisk/LinuxGuanjia/${version}/baidunetdisk_${version}_amd64.deb";
      hash = "sha256-rTpM4/29u0TT4Vf6By9pLAYpvn5ulOkVHPw0CMDVuiM=";
    };

    nativeBuildInputs = [
      autoPatchelfHook
      dpkg
    ];
    buildInputs = runtimeLibraries;

    dontBuild = true;
    dontConfigure = true;

    unpackPhase = ''
      runHook preUnpack
      dpkg-deb -x "$src" .
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/opt" "$out/share"
      cp -a opt/baidunetdisk "$out/opt/"
      cp -a usr/share/icons "$out/share/"

      runHook postInstall
    '';

    meta = {
      description = "Baidu Netdisk Linux client payload";
      homepage = "https://pan.baidu.com/download";
      license = lib.licenses.unfree;
      platforms = ["x86_64-linux"];
    };
  };

  launcher = pkgs.writeShellApplication {
    name = "baidunetdisk";
    runtimeInputs = with pkgs; [
      bubblewrap
      coreutils
      xdg-dbus-proxy
    ];

    text = ''
      set -euo pipefail

      uid="$(id -u)"
      user="$(id -un)"
      host_home="''${HOME:?HOME is not set}"
      sandbox_root="''${XDG_DATA_HOME:-$host_home/.local/share}/baidunetdisk-sandbox"
      sandbox_home="$sandbox_root/home"
      runtime_dir="''${XDG_RUNTIME_DIR:-/run/user/$uid}"

      mkdir -p "$sandbox_home" "$host_home/Downloads"

      bwrap_args=(
        --die-with-parent
        --new-session
        --unshare-pid
        --unshare-uts
        --unshare-ipc
        --clearenv
        --ro-bind /nix/store /nix/store
        --dir /run
        --dir /run/user
        --dir "/run/user/$uid"
        --ro-bind /run/current-system /run/current-system
        --ro-bind /etc /etc
        --dev /dev
        --proc /proc
        --tmpfs /tmp
        --dir /tmp/.X11-unix
        --dir /home
        --dir "/home/$user"
        --bind "$sandbox_home" "/home/$user"
        --bind "$host_home/Downloads" "/home/$user/Downloads"
        --chdir "/home/$user"
        --dir /opt
        --ro-bind "${payload}/opt/baidunetdisk" /opt/baidunetdisk
        --setenv HOME "/home/$user"
        --setenv USER "$user"
        --setenv LOGNAME "$user"
        --setenv PATH "${lib.makeBinPath [pkgs.coreutils pkgs.glib pkgs.xdg-utils]}"
        --setenv LD_LIBRARY_PATH "/opt/baidunetdisk:${lib.makeLibraryPath runtimeLibraries}"
        --setenv XDG_RUNTIME_DIR "/run/user/$uid"
        --setenv XDG_DATA_HOME "/home/$user/.local/share"
        --setenv XDG_CONFIG_HOME "/home/$user/.config"
        --setenv XDG_CACHE_HOME "/home/$user/.cache"
        --setenv LANG "''${LANG:-C.UTF-8}"
        --setenv XDG_CURRENT_DESKTOP "''${XDG_CURRENT_DESKTOP:-KDE}"
        --setenv GTK_USE_PORTAL 1
        --setenv ELECTRON_OZONE_PLATFORM_HINT auto
        --setenv SSL_CERT_FILE /etc/ssl/certs/ca-bundle.crt
      )

      if [ -d /run/current-system/sw/share ]; then
        bwrap_args+=(--dir /usr --ro-bind /run/current-system/sw/share /usr/share)
      fi

      if [ -d /dev/dri ]; then
        bwrap_args+=(--dev-bind /dev/dri /dev/dri)
      fi

      if [ -n "''${WAYLAND_DISPLAY:-}" ] && [ -S "$runtime_dir/$WAYLAND_DISPLAY" ]; then
        bwrap_args+=(
          --bind "$runtime_dir/$WAYLAND_DISPLAY" "/run/user/$uid/$WAYLAND_DISPLAY"
          --setenv WAYLAND_DISPLAY "$WAYLAND_DISPLAY"
        )
      fi

      if [ -n "''${DISPLAY:-}" ] && [ -d /tmp/.X11-unix ]; then
        bwrap_args+=(--ro-bind /tmp/.X11-unix /tmp/.X11-unix --setenv DISPLAY "$DISPLAY")

        xauthority="''${XAUTHORITY:-$host_home/.Xauthority}"
        if [ -f "$xauthority" ]; then
          bwrap_args+=(--ro-bind "$xauthority" /tmp/.Xauthority --setenv XAUTHORITY /tmp/.Xauthority)
        fi
      fi

      if [ -S "$runtime_dir/pipewire-0" ]; then
        bwrap_args+=(--bind "$runtime_dir/pipewire-0" "/run/user/$uid/pipewire-0")
      fi

      if [ -S "$runtime_dir/pulse/native" ]; then
        bwrap_args+=(
          --dir "/run/user/$uid/pulse"
          --bind "$runtime_dir/pulse/native" "/run/user/$uid/pulse/native"
          --setenv PULSE_SERVER "unix:/run/user/$uid/pulse/native"
        )
      fi

      if [ -d "$runtime_dir/doc" ]; then
        bwrap_args+=(--ro-bind "$runtime_dir/doc" "/run/user/$uid/doc")
      fi

      proxy_pid=""
      proxy_socket="$sandbox_root/dbus-proxy-$uid-$$"
      cleanup() {
        if [ -n "$proxy_pid" ]; then
          kill "$proxy_pid" 2>/dev/null || true
          wait "$proxy_pid" 2>/dev/null || true
          rm -f "$proxy_socket"
        fi
      }
      trap cleanup EXIT

      if [ -S "$runtime_dir/bus" ]; then
        rm -f "$proxy_socket"
        xdg-dbus-proxy "unix:path=$runtime_dir/bus" "$proxy_socket" \
          --filter \
          --talk=org.freedesktop.portal.Desktop \
          --talk=org.freedesktop.portal.Documents \
          --talk=org.freedesktop.Notifications \
          --talk=org.kde.StatusNotifierWatcher &
        proxy_pid=$!

        for _ in $(seq 1 50); do
          if [ -S "$proxy_socket" ]; then
            break
          fi
          if ! kill -0 "$proxy_pid" 2>/dev/null; then
            if wait "$proxy_pid"; then
              printf '无法启动百度网盘的 D-Bus 代理。\n' >&2
              exit 1
            else
              proxy_status=$?
              printf '百度网盘的 D-Bus 代理退出，状态码：%s。\n' "$proxy_status" >&2
              exit "$proxy_status"
            fi
          fi
          sleep 0.1
        done

        if [ ! -S "$proxy_socket" ]; then
          printf '百度网盘的 D-Bus 代理未能及时启动。\n' >&2
          exit 1
        fi

        bwrap_args+=(
          --bind "$proxy_socket" "/run/user/$uid/bus"
          --setenv DBUS_SESSION_BUS_ADDRESS "unix:path=/run/user/$uid/bus"
        )
      fi

      # Keep bubblewrap isolation but avoid Chromium's clone3 SIGSYS on current glibc.
      bwrap "''${bwrap_args[@]}" -- /opt/baidunetdisk/baidunetdisk --disable-seccomp-filter-sandbox "$@"
    '';
  };

  desktopItem = pkgs.makeDesktopItem {
    name = "baidunetdisk";
    desktopName = "百度网盘";
    comment = "百度网盘 Linux 客户端";
    exec = "baidunetdisk %U";
    icon = "baidunetdisk";
    terminal = false;
    categories = ["Network" "FileTransfer"];
    mimeTypes = ["x-scheme-handler/baiduyunguanjia"];
    startupWMClass = "baidunetdisk";
    extraConfig = {
      "Name[zh_CN]" = "百度网盘";
    };
  };
in
  pkgs.symlinkJoin {
    name = "baidunetdisk-${version}";
    paths = [
      payload
      launcher
      desktopItem
    ];

    meta = {
      description = "Baidu Netdisk Linux client isolated with bubblewrap";
      homepage = "https://pan.baidu.com/download";
      license = lib.licenses.unfree;
      mainProgram = "baidunetdisk";
      platforms = ["x86_64-linux"];
    };
  }
