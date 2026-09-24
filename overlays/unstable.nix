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

  xrizer = unstable.xrizer.overrideAttrs (old: rec {
    version = "0.5-unstable-2026-09-03";
    src = unstable.fetchFromGitHub {
      owner = "Supreeeme";
      repo = "xrizer";
      rev = "0989a7fac2d1efb7ea82f5fe1a8ed30c3eeb9596";
      hash = "sha256-Rb1pssAq6Zx6VmQVQtGcThkA6zCwi5X7G7aHmdsDrJo=";
    };
    cargoDeps = unstable.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-JKQUrHGqnU5453iVKXnO51nX2NqcBYzsfvuu92WhLDE=";
    };
    postPatch = ''
      substituteInPlace Cargo.toml \
        --replace-fail 'static-openxr = ["openxr/static"]' 'static-openxr = ["openxr/linked"]' \
        --replace-fail 'default = ["monado", "git-version"]' 'default = ["monado", "git-version", "static-openxr"]'
      substituteInPlace src/graphics_backends/gl.rs \
        --replace-fail 'libGLX.so.0' '${unstable.lib.getLib unstable.libGL}/lib/libGLX.so.0'
    '';
    env =
      (old.env or {})
      // {
        XRIZER_VERSION = "0.5-unstable-0989a7f";
      };
  });

  wivrn = unstable.wivrn.override {
    inherit xrizer;
  };
in {
  # 只 inherit 26.05 没有、或稳定版过旧必须用 unstable 的包
  inherit
    (unstable)
    code-cursor
    cursor-cli
    github-copilot-cli
    qbittorrent-enhanced
    qq
    aider-chat-full
    intiface-central
    zed-editor
    pi-coding-agent
    steam
    proton-ge-bin
    opencomposite
    wayvr
    ;
  inherit xrizer wivrn;
}
