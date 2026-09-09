{
  plugins = {
    luasnip.enable = true;

    # Provides VSCode-style snippets for blink's snippets source.
    friendly-snippets.enable = true;

    blink-cmp = {
      enable = true;
      setupLspCapabilities = true;

      settings = {
        # Agentic owns slash-command / file-picker completion in its prompt.
        enabled.__raw = ''
          function()
            return not vim.tbl_contains({ "AgenticInput" }, vim.bo.filetype)
          end
        '';

        keymap.preset = "super-tab";

        # Avoid completion menu inside snippets conflicting with Tab accept/jump.
        completion.trigger.show_in_snippet = false;

        appearance.nerd_font_variant = "mono";

        completion.documentation = {
          auto_show = true;
          auto_show_delay_ms = 200;
        };

        # Metals often labels vals / parameterless defs as Method, and its
        # semantic tokens are similarly noisy — same class of issue as Java.
        completion.accept.auto_brackets = {
          kind_resolution = {
            enabled = true;
            blocked_filetypes = [
              "typescriptreact"
              "javascriptreact"
              "vue"
              "scala"
              "sbt"
            ];
          };
          semantic_token_resolution = {
            enabled = true;
            blocked_filetypes = [
              "java"
              "scala"
              "sbt"
            ];
          };
        };

        snippets.preset = "luasnip";

        sources.default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
        ];

        signature.enabled = true;
      };
    };
  };
}
