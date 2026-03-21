{
  ...
}:
{
  # Create autostart desktop entry for 1Password
  xdg.configFile."autostart/1password.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=1Password
    Exec=1password
    Icon=1password
    Terminal=false
    Categories=Utility;Security;
    StartupNotify=false
  '';
}
