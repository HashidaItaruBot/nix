{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    kdePackages.kate
    kdePackages.dolphin
    firefox
    _1password-cli
  ];

}

