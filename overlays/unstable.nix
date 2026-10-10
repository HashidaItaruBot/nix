# Pure overlay: lift selected packages from nixpkgs-unstable onto pkgs.
inputs: final: prev: let
  unstable = import inputs.nixpkgs-unstable {
    system = prev.stdenv.hostPlatform.system;
    config = {
      allowUnfree = true;
      # 若某 unstable 包需要，再按需打开
      # allowUnfreePredicate = ...;
    };
  };
in {
  # 只 inherit 26.05 没有、或稳定版过旧必须用 unstable 的包
  inherit
    (unstable)
    code-cursor
    cursor-cli
    qbittorrent-enhanced
    qq
    aider-chat-full
    intiface-central
    zed-editor
    pi-coding-agent
    wivrn
    steam
    proton-ge-bin
    monado
    ;
}
