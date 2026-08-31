{
  plugins.telescope = {
    enable = true;
    extensions = {
      fzf-native.enable = true;
      ui-select.enable = true;
    };
    keymaps = {
      "<leader>sh" = {
        mode = "n";
        action = "help_tags";
        options.desc = "[S]earch [H]elp";
      };
      "<leader>sk" = {
        mode = "n";
        action = "keymaps";
        options.desc = "[S]earch [K]eymaps";
      };
      "<leader>sf" = {
        mode = "n";
        action = "find_files";
        options.desc = "[S]earch [F]iles";
      };
      "<leader>sw" = {
        mode = "n";
        action = "grep_string";
        options.desc = "[S]earch current [W]ord";
      };
      "<leader>sg" = {
        mode = "n";
        action = "live_grep";
        options.desc = "[S]earch by [G]rep";
      };
      "<leader>sd" = {
        mode = "n";
        action = "diagnostics";
        options.desc = "[S]earch [D]iagnostics";
      };
      "<leader>sr" = {
        mode = "n";
        action = "resume";
        options.desc = "[S]earch [R]esume";
      };
      "<leader>s." = {
        mode = "n";
        action = "oldfiles";
        options.desc = "[S]earch Recent Files";
      };
      "<leader><leader>" = {
        mode = "n";
        action = "buffers";
        options.desc = "Find existing buffers";
      };
    };
    settings.extensions.__raw = "{ ['ui-select'] = { require('telescope.themes').get_dropdown() } }";
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>/";
      action.__raw = ''
        function()
          require('telescope.builtin').current_buffer_fuzzy_find(
            require('telescope.themes').get_dropdown {
              winblend = 10,
              previewer = false,
            }
          )
        end
      '';
      options.desc = "[/] Fuzzily search in current buffer";
    }
  ];
}
