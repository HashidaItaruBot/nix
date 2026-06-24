_: {
  xdg.configFile = {
    "rofi/config.rasi".source = ./content/config.rasi;
    "rofi/powermenu.rasi".source = ./content/powermenu.rasi;
    "rofi/powermenu.sh" = {
      source = ./content/powermenu.sh;
      executable = true;
    };
  };
}
