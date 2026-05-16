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

    bayesdl_api_key = {
      sopsFile = "${self}/shared/secrets/api_keys.yaml";
      owner = "root";
      mode = "0400";
    };
  };
}
