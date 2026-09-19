{
  inputs,
  pkgs,
  ...
}: {
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
      # Anime Games Launcher v2.2.0
      # https://github.com/an-anime-team/agl-flatpak
      rec {
        appId = "moe.launcher.anime-games-launcher";
        sha256 = "1h16q1y8jw7jssmq849wq9m18zvcjgrj3jmmsqap27dl3wz6ssnk";
        bundle = "${pkgs.fetchurl {
          url = "https://github.com/an-anime-team/agl-flatpak/releases/download/v2.2.0/anime-games-launcher.flatpak";
          name = "moe.launcher.anime-games-launcher.flatpak";
          inherit sha256;
        }}";
      }
      # bundle 不会自动拉取 32 位 Mesa；这台机器是 AMD GPU
      "org.freedesktop.Platform.GL32.default//25.08"
    ];
  };
}
