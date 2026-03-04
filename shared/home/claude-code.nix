{ pkgs, ... }:

{
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code;

    mcpServers = {
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
    };
  };
}