{
  lib,
  pkgs,
  ...
}: let
  waydroid = pkgs.waydroid-nftables;
  user = "zhaochanglong";
  # Lineage 20（Android 13）用 AIDL3。NixOS 模块默认写成 aidl2，容器会起不来。
  gbinderConf = pkgs.writeText "waydroid.conf" ''
    [Protocol]
    /dev/binder = aidl3
    /dev/vndbinder = aidl3
    /dev/hwbinder = hidl

    [ServiceManager]
    /dev/binder = aidl3
    /dev/vndbinder = aidl3
    /dev/hwbinder = hidl
  '';
  initScript = pkgs.writeShellScript "waydroid-init-gapps" ''
    set -euo pipefail
    cfg=/var/lib/waydroid/waydroid.cfg
    if [[ -f "$cfg" ]] && grep -q 'system/lineage/waydroid_x86_64/GAPPS.json' "$cfg"; then
      exit 0
    fi
    if systemctl is-active --quiet waydroid-container.service; then
      systemctl stop waydroid-container.service
    fi
    # 现有镜像是 VANILLA，用户数据不能和 GApps 混用。
    rm -rf /home/${user}/.local/share/waydroid
    ${waydroid}/bin/waydroid init -f -s GAPPS
  '';
  androidId = pkgs.writeShellScriptBin "waydroid-android-id" ''
    set -euo pipefail
    db="$HOME/.local/share/waydroid/data/data/com.google.android.gsf/databases/gservices.db"
    if [[ ! -f "$db" ]]; then
      echo "还没有 gservices.db。请先运行 waydroid show-full-ui，打开一次 Play 商店后再执行本命令。" >&2
      exit 1
    fi
    id=$(${pkgs.sqlite}/bin/sqlite3 "$db" "select value from main where name = 'android_id';")
    if [[ -z "''${id}" ]]; then
      echo "android_id 还没生成。先关掉 VPN，确认 Waydroid 能访问外网，打开一次 Play 商店后再试。" >&2
      exit 1
    fi
    echo "Android ID: $id"
    echo "用谷歌账号打开并注册这个 ID："
    echo "https://www.google.com/android/uncertified/"
    echo "注册后等 10 到 20 分钟，再执行 waydroid session stop，然后重新打开 Waydroid。"
  '';
in {
  virtualisation.waydroid = {
    enable = true;
    # 内核 6.17+（当前是 7.1 zen）不能再用 iptables 版。
    package = waydroid;
  };

  environment.etc."gbinder.d/waydroid.conf".source = lib.mkForce gbinderConf;

  environment.systemPackages = [androidId];

  systemd.services.waydroid-init-gapps = {
    description = "Initialize Waydroid with Google Apps images";
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    wants = ["network-online.target"];
    before = ["waydroid-container.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutStartSec = "45min";
      ExecStart = initScript;
    };
  };

  systemd.services.waydroid-container = {
    after = ["waydroid-init-gapps.service"];
    requires = ["waydroid-init-gapps.service"];
  };
}
