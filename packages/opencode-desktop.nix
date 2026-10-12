# OpenCode desktop 官方源码（含其 flake 的 nix 打包）存在后台服务注册文件
# 命名不一致：
#   - CLI（channel=prod，由上游 nix/opencode.nix 烙死）serve --service 只写
#     `$XDG_STATE_HOME/opencode/service-prod.json`
#   - desktop 的 Service.ensure 固定读通用的 `service.json`
#     （packages/client/src/service-probe.ts 的 fallback()）
# 官方预编译 desktop 内 bundled CLI 的 channel 是 latest（CI 里
# OPENCODE_VERSION 非预览版 → Script.channel=latest），所以官方包不受影响；
# 本 flake 源码构建的组合必然触发 desktop "Timed out waiting for the
# background service to start"。
#
# 处理：启动前把 service.json 重建为指向 service-prod.json 的软链接。
# desktop 的失败清理路径会 rm service.json，所以放在启动器里每次执行。
# 注意 symlinkJoin 里 launcher 放在 desktop 前面：lndir 对已存在文件跳过，
# 这样 $out/bin/opencode-desktop 用 launcher 覆盖原始二进制。
{
  symlinkJoin,
  writeShellScriptBin,
  opencode-desktop,
}: let
  launcher = writeShellScriptBin "opencode-desktop" ''
    state="''${XDG_STATE_HOME:-$HOME/.local/state}/opencode"
    mkdir -p "$state"
    ln -sfn service-prod.json "$state/service.json"
    exec ${opencode-desktop}/bin/opencode-desktop "$@"
  '';
in
  symlinkJoin {
    name = "${opencode-desktop.pname}-${opencode-desktop.version}";
    paths = [
      launcher
      opencode-desktop
    ];
    meta = {
      description = "OpenCode Desktop（service.json 软链接 wrapper，修复源码构建的后台服务注册文件名不一致）";
      inherit (opencode-desktop.meta) mainProgram license platforms homepage;
    };
  }
