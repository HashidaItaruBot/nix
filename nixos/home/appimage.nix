{
  config,
  lib,
  pkgs,
  ...
}: {
  # Create desktop entry for appimage-run
  xdg.desktopEntries.appimage-run = {
    name = "AppImage Runner";
    exec = "appimage-run %f";
    icon = "application-x-executable";
    mimeType = [
      "application/vnd.appimage"
      "application/x-executable"
    ];
    terminal = false;
    categories = ["Utility"];
  };

  # Set default application for AppImage files
  xdg.mimeApps.defaultApplications = {
    "application/vnd.appimage" = "appimage-run.desktop";
    "application/x-executable" = "appimage-run.desktop";
  };
}
