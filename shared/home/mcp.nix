{ osConfig, ... }: {
  programs.mcp.servers = {
    playwright = {
      type = "stdio";
      command = "npx";
      args = [
        "-y"
        "@anthropic-ai/mcp-server-playwright"
      ];
    };
    sequential-thinking = {
      type = "stdio";
      command = "npx";
      args = [
        "-y"
        "@modelcontextprotocol/server-sequential-thinking"
      ];
    };
    exa-web-search = {
      type = "stdio";
      command = "npx";
      args = [
        "-y"
        "exa-mcp-server"
      ];
      env.EXA_API_KEY.file = osConfig.sops.secrets.exa_api_key.path;
    };
  };
}
