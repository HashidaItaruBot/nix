{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./base.nix
    ./colorscheme.nix
    ./options.nix
    ./clipboard.nix
    ./extra-plugins.nix

    # 插件配置
    ./plugins

    # 键盘映射配置
    ./keymaps
  ];
}
