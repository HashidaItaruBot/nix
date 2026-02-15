{
  self,
  inputs,
  config,
  ...
}:

let
  # Generate a deterministic gateway token based on self path
  gatewayToken = builtins.hashString "sha256" (toString self);
in
{
  imports = [
    inputs.nix-openclaw.homeManagerModules.openclaw
  ];

  programs.openclaw = {
    documents = ./documents;

    config = {
      gateway = {
        mode = "local";
        auth.token = gatewayToken;
      };

      channels.telegram = {
        tokenFile = config.sops.secrets.telegram_bot_token;
        allowFrom = [ 1622558025 ];
        groups."*" = {
          requireMention = true;
        };
      };
    };

    # Use instances.default for more control
    instances.default = {
      enable = true;
      # Use openclaw-gateway package to avoid Python conflicts
      #package = pkgs.openclaw-gateway;
      #stateDir = "~/.openclaw";
      #workspaceDir = "~/.openclaw/workspace";
      #launchd.enable = true;

      # Plugins (optional)
      plugins = [
        # Add plugins here
      ];
    };
  };
}
