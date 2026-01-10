{ inputs, ... }:
{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
  ];
  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true; # 每次 rebuild 时检查更新
  services.flatpak.remotes = [
    {
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }
  ];
  services.flatpak.packages = [
      "com.usebottles.bottles"
  ];
}
