{inputs, ...}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
    # 脚手架：基础 options + 常用插件。AI（copilot / codecompanion）后续再加。
    imports = [
      ./options.nix
      ./keymaps.nix
      ./plugins
    ];
  };
}
