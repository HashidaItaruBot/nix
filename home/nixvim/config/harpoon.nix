{lib, ...}: {
  plugins.harpoon = {
    enable = true;
    enableTelescope = true;

    settings = {
      settings = {
        save_on_toggle = true;
        sync_on_ui_close = true;
      };
    };
  };

  keymaps =
    [
      {
        mode = "n";
        key = "<leader>ha";
        action.__raw = "function() require('harpoon'):list():add() end";
        options.desc = "Harpoon add file";
      }
      {
        mode = "n";
        key = "<leader>hh";
        action.__raw = "function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end";
        options.desc = "Harpoon menu";
      }
      {
        mode = "n";
        key = "<leader>hp";
        action.__raw = "function() require('harpoon'):list():prev() end";
        options.desc = "Harpoon prev";
      }
      {
        mode = "n";
        key = "<leader>hn";
        action.__raw = "function() require('harpoon'):list():next() end";
        options.desc = "Harpoon next";
      }
      {
        mode = "n";
        key = "<leader>fh";
        action = "<cmd>Telescope harpoon marks<CR>";
        options.desc = "Harpoon marks";
      }
    ]
    ++ lib.genList (i: {
      mode = "n";
      key = "<leader>h${toString (i + 1)}";
      action.__raw = "function() require('harpoon'):list():select(${toString (i + 1)}) end";
      options.desc = "Harpoon file ${toString (i + 1)}";
    })
    4;
}
