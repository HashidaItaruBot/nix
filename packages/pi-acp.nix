# pi-acp: ACP (Agent Client Protocol) adapter for pi coding agent.
# 桥接 agentic.nvim (ACP 客户端) ↔ `pi --mode rpc` 子进程。
# 上游: https://github.com/svkozak/pi-acp (MIT)。
# 依赖运行时的 pi 二进制 (nixpkgs pi-coding-agent)，必须同时在 PATH。
{
  fetchFromGitHub,
  buildNpmPackage,
  nodejs,
}:
buildNpmPackage {
  pname = "pi-acp";
  version = "0.0.34";
  nodejs = nodejs; # 上游要求 node >=20

  src = fetchFromGitHub {
    owner = "svkozak";
    repo = "pi-acp";
    rev = "v0.0.34";
    hash = "sha256-QRwxOtTZOY+Np3PkAoy2o2PrUzEqjItM/372sCPlSMo=";
  };

  npmDepsHash = "sha256-BvLNtFfp1cMVjzWcMRSdhTqiJrTfbFoUbWkkPW9200o=";

  # layout: $out/lib/node_modules/pi-acp/dist/index.js + $out/bin/pi-acp (npmInstallHook 默认基于 package.json bin)
}
