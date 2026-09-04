{
  plugins.codecompanion = {
    enable = true;

    settings = {
      # Cursor Agent via ACP (`agent acp`). Requires `agent login` once.
      adapters.acp = {
        cursor_cli.__raw = ''
          function()
            return require("codecompanion.adapters").extend("cursor_cli", {
              commands = {
                default = { "agent", "acp" },
              },
              defaults = {
                timeout = 30000,
              },
            })
          end
        '';
      };

      # `strategies` is accepted and mapped to `interactions` in v19+.
      # ACP is best suited to chat; leave inline on the plugin default.
      strategies.chat.adapter = "cursor_cli";

      display = {
        action_palette.provider = "telescope";
        chat.window = {
          layout = "vertical";
          width = 0.4;
        };
      };

      opts = {
        log_level = "ERROR";
        send_code = true;
      };
    };
  };

  keymaps = [
    {
      mode = ["n" "v"];
      key = "<leader>aa";
      action = "<cmd>CodeCompanionActions<CR>";
      options.desc = "CodeCompanion actions";
    }
    {
      mode = ["n" "v"];
      key = "<leader>ac";
      action = "<cmd>CodeCompanionChat Toggle<CR>";
      options.desc = "Toggle CodeCompanion chat";
    }
    {
      mode = "v";
      key = "<leader>ae";
      action = "<cmd>CodeCompanionChat Add<CR>";
      options.desc = "Add selection to chat";
    }
  ];
}
