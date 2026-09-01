{
  plugins.neo-tree = {
    enable = true;
    settings = {
      close_if_last_window = true;
      filesystem = {
        follow_current_file = {
          enabled = true;
          leave_dirs_open = true;
        };
        window.mappings."\\" = "close_window";
      };
    };
  };

  keymaps = [
    {
      key = "<leader>e";
      action = "<cmd>Neotree reveal<cr>";
      options.desc = "NeoTree reveal";
    }
  ];
}
