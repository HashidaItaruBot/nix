{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    kdePackages.kate
    kdePackages.dolphin
    firefox
    _1password-cli
    code-cursor
    alacritty
    obsidian
    telegram-desktop
    vlc
    qbittorrent
  ];

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "zhaochanglong" ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # 如果需要远程串流
  };
}

