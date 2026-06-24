_: {
  xdg.configFile = {
    "rofi/config.rasi".source = ./config.rasi;
    "rofi/powermenu.rasi".source = ./powermenu.rasi;
    "rofi/powermenu.sh" = {
      source = ./powermenu.sh;
      executable = true;
    };
  };
}
