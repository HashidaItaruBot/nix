{ inputs, ... }:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
    # 开启 LazyVim 预设
    plugins.lazyvim = {
      enable = true;
      installLazyVim = true; # 这会自动引用 vimPlugins.LazyVim
    };

    # 依然可以自定义配置
    opts = {
      number = true;
      shiftwidth = 2;
    };
  };
}
