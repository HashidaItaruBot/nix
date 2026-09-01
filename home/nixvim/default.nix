{inputs, ...}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
    # 基于 https://github.com/JMartJonesy/kickstart.nixvim
    imports = [
      ./options.nix
      ./keymaps.nix
      ./plugins
    ];
  };
}
