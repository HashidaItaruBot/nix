{
  plugins = {
    luasnip.enable = true;

    # Provides VSCode-style snippets for blink's snippets source.
    friendly-snippets.enable = true;

    blink-cmp = {
      enable = true;
      setupLspCapabilities = true;

      settings = {
        keymap.preset = "super-tab";

        # Avoid completion menu inside snippets conflicting with Tab accept/jump.
        completion.trigger.show_in_snippet = false;

        appearance.nerd_font_variant = "mono";

        completion.documentation = {
          auto_show = true;
          auto_show_delay_ms = 200;
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
