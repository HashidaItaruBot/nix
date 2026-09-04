{
  plugins.toggleterm = {
    enable = true;

    settings = {
      direction = "float";
      float_opts = {
        border = "rounded";
      };
      shade_terminals = true;
      start_in_insert = true;
      persist_mode = false;
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>tt";
      action = "<cmd>ToggleTerm direction=float<CR>";
      options.desc = "Toggle floating terminal";
    }
    {
      mode = "n";
      key = "<leader>th";
      action = "<cmd>ToggleTerm direction=horizontal size=15<CR>";
      options.desc = "Toggle horizontal terminal";
    }
    {
      mode = "n";
      key = "<leader>tv";
      action = "<cmd>ToggleTerm direction=vertical size=60<CR>";
      options.desc = "Toggle vertical terminal";
    }
    {
      mode = "t";
      key = "<Esc>";
      action = "<C-\\><C-n>";
      options.desc = "Exit terminal mode";
    }
  ];
}
