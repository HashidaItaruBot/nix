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
    # Exa 搜索引擎 API key
    exa_api_key = {
      sopsFile = "${self}/shared/secrets/api_keys.yaml";
      owner = "zhaochanglong";
      mode = "0400";
    };
    deepseek_api_key = {
      sopsFile = "${self}/shared/secrets/api_keys.yaml";
      owner = "zhaochanglong";
      mode = "0400";
    };
  };

  environment.extraInit = ''
    export EXA_API_KEY="$(cat ${config.sops.secrets.exa_api_key.path})"
    export DEEPSEEK_API_KEY="$(cat ${config.sops.secrets.deepseek_api_key.path})"
  '';
}
