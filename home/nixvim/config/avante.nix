{
  # Avante sidebar needs a global statusline to collapse cleanly.
  opts.laststatus = 3;

  plugins = {
    # Render Avante chat / sidebar markdown.
    render-markdown = {
      enable = true;
      settings.file_types = [
        "markdown"
        "Avante"
      ];
    };

    avante = {
      enable = true;
      settings = {
        # Cursor CLI via ACP (official integration path).
        # Authenticate first: `agent login`
        provider = "cursor";
        mode = "agentic";

        acp_providers.cursor = {
          command.__raw = ''os.getenv("HOME") .. "/.local/bin/agent"'';
          args = ["acp"];
          auth_method = "cursor_login";
          env = {
            HOME.__raw = ''os.getenv("HOME")'';
            PATH.__raw = ''os.getenv("PATH")'';
          };
        };

        behaviour = {
          auto_suggestions = false;
        };

        hints.enabled = true;

        windows = {
          wrap = true;
          width = 30;
          sidebar_header = {
            align = "center";
            rounded = true;
          };
        };
      };
    };
  };
}
