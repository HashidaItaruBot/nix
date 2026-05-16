{ config, ... }:
{
  environment.extraInit = ''
    export BAYESDL_API_KEY="$(cat ${config.sops.secrets.bayesdl_api_key.path})";
  '';
}
