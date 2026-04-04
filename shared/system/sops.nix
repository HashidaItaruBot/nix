{ self
, config
, ...
}: {
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
    zai_api_key = {
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

  environment.extraInit = ''
    export DEEPSEEK_API_KEY="$(cat ${config.sops.secrets.deepseek_api_key.path})"
    export ALIBABA_API_KEY="$(cat ${config.sops.secrets.alibaba_api_key.path})"
    export ANTHROPIC_AUTH_TOKEN="$(cat ${config.sops.secrets.zai_api_key.path})"
    export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
    export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.5-air"
    export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-4.7"
    export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.1"
    export TELEGRAM_BOT_TOKEN=$(cat ${config.sops.secrets.telegram_bot_token.path})
  '';
}
