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

        # super-tab navigation, but Tab only accepts when an item is
        # selected (not via select_and_accept).
        keymap = {
          preset = "super-tab";
          # Tab 三态：blink 菜单有选中 → 走后续 'accept' 接受 blink 候选；
          # 菜单开但未选中 (preselect=false 现状) → 接受 minuet ghost text；
          # 菜单关闭 → 接受 ghost text；连 ghost 也没有 → 继续列表
          # ('accept' 无选中为 no-op) → snippet 跳转 → 原生 fallback。
          # python keymap 函数返回 true 中止、nil 继续下一项 (blink 1.10.2 语义)。
          "<Tab>".__raw = ''
            {
              function()
                local bc = require('blink.cmp')
                local mvt = require('minuet.virtualtext')
                if bc.is_menu_visible() then
                  if bc.get_selected_item() ~= nil then
                    return -- fallthrough 到 'accept'（接受 blink 选中项）
                  end
                  if mvt.action.is_visible() then
                    mvt.action.accept()
                    return true
                  end
                  return
                end
                if mvt.action.is_visible() then
                  mvt.action.accept()
                  return true
                end
              end,
              'accept',
              'snippet_forward',
              'fallback',
            }
          '';
        };

        # Do not preselect the first item; Tab then prefers navigation
        # unless the user has navigated the menu (C-n/C-p, arrows).
        completion.list.selection = {
          preselect = false;
          auto_insert = false;
        };

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
