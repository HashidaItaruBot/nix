{ pkgs, ... }: {
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
    zoxide
    bat
    
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
    
    # TeX Live
    texlive.combined.scheme-full

    ssh-to-age
    sops
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    sarasa-gothic
    corefonts
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    nerd-fonts.hack
    nerd-fonts.noto
  ];

  programs.zsh.enable = true;

  nixpkgs.config.allowUnfree = true;

  nix.package = pkgs.lixPackageSets.stable.lix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
