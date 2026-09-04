{
  plugins = {
    # Diff UI used by Neogit for richer commit / file diffs.
    diffview.enable = true;

    neogit = {
      enable = true;

      settings = {
        kind = "tab";
        integrations = {
          diffview = true;
          telescope = true;
        };
      };
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>gg";
      action = "<cmd>Neogit<CR>";
      options.desc = "Neogit status";
    }
  ];
}
