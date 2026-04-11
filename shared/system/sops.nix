{
  self,
  config,
  ...
}:
{
  sops.secrets = {
    # mihomo 配置
    mihomo_config = {
      sopsFile = "${self}/shared/secrets/mihomo_config.yaml";
      key = "data";
      owner = "root";
      mode = "0400";
    };
    # deepseek api key
    deepseek_api_key = {
      sopsFile = "${self}/shared/secrets/api_keys.yaml";
      owner = "root";
      mode = "0400";
    };
    # alibaba api key (用于opencode)
    alibaba_api_key = {
      sopsFile = "${self}/shared/secrets/api_keys.yaml";
      owner = "root";
      mode = "0400";
    };

    telegram_bot_token = {
      sopsFile = "${self}/shared/secrets/telegram_bot_token.yaml";
      owner = "root";
      mode = "0400";
    };
  };
}
