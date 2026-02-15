{ self, inputs, pkgs, ... }:

let
  # Generate a deterministic gateway token based on self path
  gatewayToken = builtins.hashString "sha256" (toString self);
in
{
  imports = [
    inputs.nix-openclaw.homeManagerModules.openclaw
  ];

  programs.openclaw = {
    # Path to documents directory (contains AGENTS.md, SOUL.md, TOOLS.md, etc.)
    documents = self + "/documents";

    config = {
      gateway = {
        mode = "local";
        auth.token = gatewayToken;
      };

      channels.telegram = {
        tokenFile = "/run/secrets/telegram_bot_token";
        allowFrom = [ 1622558025 ];
        groups."*" = { requireMention = true; };
      };
    };

    # Use instances.default for more control
    instances.default = {
      enable = true;
      # Use the bundled package from overlay
      package = pkgs.openclaw;
      stateDir = "~/.openclaw";
      workspaceDir = "~/.openclaw/workspace";
      launchd.enable = true;

      # Plugins (optional)
      plugins = [
        # Add plugins here
      ];
    };
  };
}