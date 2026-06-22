{
  pkgs,
  self,
  inputs,
  ...
}:
let
  ecc-universal = pkgs.callPackage "${self}/shared/packages/ecc-universal.nix" { };
  langcli = pkgs.callPackage "${self}/shared/packages/langcli.nix" { };
  codewhale =
    inputs.codewhale.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs
      (_: {
        doCheck = false; # 17 tests fail on macOS due to sandbox-exec restrictions
      });
in
{
  imports = [
    ./sops.nix
  ];

  environment.systemPackages = with pkgs; [
    codewhale
    # Core tools
    vim
    git
    gh # GitHub CLI
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

    # Development
    gnumake
    gcc
    clang
    cmake
    nodejs
    ecc-universal
    rtk
    langcli
    pnpm
    gdb

    qemu
    nh

    ssh-to-age
    sops
    openssh

    # Nix开发工具
    nixd
    nil
    alejandra
    statix
    nom

    logisim-evolution

    # Chisel开发工具
    sbt
    jdk8
    verilator
    gtkwave
  ];

  fonts.packages = with pkgs; [
    wqy_microhei
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
  programs._1password.enable = true;

  users.users.zhaochanglong = {
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;

  nix.package = pkgs.lixPackageSets.stable.lix;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
