{ pkgs, ... }: {
  # Common system configuration
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  environment.systemPackages = with pkgs; [
    # Core tools
    vim
    git
    tree
    wget
    htop
    aria2
    fd
    fzf
    ripgrep
    lazygit
    
    # Development tools
    nodejs_20
    python314
    lua
    
    # Compilers & Toolchains
    rustc
    cargo
    ghc
    cabal-install
    stack
    haskell-language-server
    gcc
    gmp
    
    # Utilities
    pnpm
    pipx
    python3Packages.jupyterlab
    qemu
    nh
    
    # TeX Live (Moved from platform specific to shared as it was in both originally or useful for both)
    # Note: TeX Live is large, consider if you want it on both. Assuming yes for consistency.
    texlive.combined.scheme-full
  ];
}
