{
  plugins.neo-tree = {
    enable = true;
    settings = {
      close_if_last_window = true;

      # Free <space> so it remains <leader> for which-key / global maps.
      # Neo-tree defaults map <space> to toggle_node, which conflicts.
      window.mappings."<space>" = "none";

      filesystem = {
        follow_current_file = {
          enabled = true;
          leave_dirs_open = true;
        };
      };
    };
  };

  keymaps = [
    {
      key = "<leader>e";
      action = "<cmd>Neotree filesystem toggle reveal<cr>";
      options.desc = "NeoTree toggle";
    }
  ];
}
