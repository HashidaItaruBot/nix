{ pkgs, ... }:
{
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

    # Development
    opencode
    gnumake
    gcc
    clang
    cmake

    qemu
    nh

    ssh-to-age
    sops

    # Nix开发工具
    nixd
    nixpkgs-fmt
    nil

    texlive.combined.scheme-full
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

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

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
