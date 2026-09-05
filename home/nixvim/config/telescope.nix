{pkgs, ...}: {
  plugins.telescope = {
    enable = true;

    keymaps = {
      "<leader>ff" = {
        action = "find_files";
        options.desc = "Find files";
      };
      "<leader>fg" = {
        action = "live_grep";
        options.desc = "Live grep";
      };
      "<leader>fb" = {
        action = "buffers";
        options.desc = "Find buffers";
      };
    };

    extensions.fzf-native = {
      enable = true;
      settings = {
        fuzzy = true;
        override_file_sorter = true;
        override_generic_sorter = true;
      };
    };

    settings = {
      defaults = {
        file_ignore_patterns = [
          "^%.git/"
          "^node_modules/"
          "^%.cache/"
          "^dist/"
          "^target/"
        ];
        layout_config.prompt_position = "top";
        selection_caret = "> ";
        sorting_strategy = "ascending";
      };

      # Search the real filesystem (incl. gitignored), but keep dotfiles hidden.
      # Explicit rg command so ignored-dir contents are listed reliably.
      pickers = {
        find_files = {
          find_command = [
            "rg"
            "--files"
            "--color"
            "never"
            "--no-ignore"
          ];
        };
        live_grep = {
          additional_args = [
            "--no-ignore"
          ];
        };
      };
    };
  };

  extraPackages = with pkgs; [
    ripgrep
  ];
}
