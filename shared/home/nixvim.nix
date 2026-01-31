{ inputs, pkgs, ... }:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
    enable = true;



    plugins.avante = {
      enable = true;
      settings = {
        provider = "deepseek";
        auto_suggestions_provider = "deepseek";
        providers = {
          deepseek = {
            __inherited_from = "openai";
            endpoint = "https://api.deepseek.com";
            api_key_name = "DEEPSEEK_API_KEY";
            model = "deepseek-coder";
          };
        };
      };
    };

    plugins.lazygit.enable = true;
    
    extraPlugins = with pkgs.vimPlugins; [
      vim-nix
    ];

    opts = {
      number = true;
      shiftwidth = 2;
    };
  };
}
