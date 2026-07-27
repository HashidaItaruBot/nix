{
  config,
  pkgs,
  ...
}: {
  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;

  # pkexec setuid wrapper — required by waydroid-helper for privileged ops
  security.wrappers.pkexec = {
    source = "${pkgs.polkit}/bin/pkexec";
    owner = "root";
    group = "root";
    setuid = true;
  };

  # Enable clipboard sharing between Waydroid and host
  environment.systemPackages = [pkgs.wl-clipboard];
}
