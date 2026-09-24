{inputs, ...}: {
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
  ];
  services.flatpak = {
    enable = true;
    update.onActivation = true; # 每次 rebuild 时检查更新
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    packages = [
      "com.usebottles.bottles"
      "com.tencent.WeChat"
      "com.geeks3d.furmark"
      "io.github.hypengw.Qcm"
      "moe.launcher.an-anime-game-launcher" # 原神 (AAGL)
      "com.baidu.NetDisk"
    ];
  };
}
