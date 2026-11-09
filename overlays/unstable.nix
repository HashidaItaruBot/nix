# Pure overlay: lift selected packages from nixpkgs-unstable onto pkgs.
inputs: final: prev: let
  unstable = import inputs.nixpkgs-unstable {
    system = prev.stdenv.hostPlatform.system;
    config = {
      allowUnfree = true;
      # enable on demand if an unstable package turns out to need it
      # allowUnfreePredicate = ...;
    };
  };
in {
  # only inherit packages missing from 26.05, or whose stable version is too outdated and must come from unstable
  inherit
    (unstable)
    code-cursor
    cursor-cli
    qbittorrent-enhanced
    qq
    podman-desktop
    zed-editor
    pi-coding-agent
    wivrn
    steam
    proton-ge-bin
    monado
    ;

  # nixpkgs cargo-setup-hook.sh (unstable since ~2026-11-06) exports
  # AWS_LC_SYS_USE_SYSTEM=1 globally for cargo builds. intiface-central
  # compiles aws-lc-sys 0.45.0 inside its internal rustDep (a buildRustPackage
  # let-binding in nixpkgs' package.nix), which wires no system AWS-LC, so the
  # pkg-config probe finds nothing and panics. rustPlatform is a callPackage
  # argument, so wrap buildRustPackage through .override to re-export 0 in
  # preBuild (after hooks, before build scripts run) and restore the vendored
  # source build. Same fix as packages/nipaplay. Drop this override once
  # upstream intiface-central handles the hook's export itself.
  intiface-central = let
    fixed = unstable.intiface-central.override (old: {
      rustPlatform =
        old.rustPlatform
        // {
          buildRustPackage = args:
            old.rustPlatform.buildRustPackage (args
              // {
                preBuild =
                  (args.preBuild or "")
                  + ''
                    export AWS_LC_SYS_USE_SYSTEM=0
                  '';
              });
        };
    });
  in
    fixed.overrideAttrs (old: {
      preBuild =
        (old.preBuild or "")
        + ''
          export AWS_LC_SYS_USE_SYSTEM=0
        '';
    });
}
