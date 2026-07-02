{pkgs, ...}: {
  programs.nixvim = {
    plugins.avante = {
      enable = true;
      settings = {
        provider = "deepseek";
        auto_suggestions_provider = "deepseek";
        providers = {
          deepseek = {
            __inherited_from = "openai";
            api_key_name = "DEEPSEEK_API_KEY";
            endpoint = "https://api.deepseek.com";
            model = "deepseek-chat";
          };
        };
        behaviour = {
          auto_set_keymaps = true;
        };
      };
    };
  };
}
