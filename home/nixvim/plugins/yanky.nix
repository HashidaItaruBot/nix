{pkgs, ...}: {
  programs.nixvim = {
    plugins.yanky = {
      enable = true;
      settings = {
        ring = {
          history_length = 100;
          storage = "shada";
          sync_with_numbered_registers = true;
          cancel_event = "update";
        };
        system_clipboard = {
          sync_with_ring = true;
        };
      };
    };

    # Yanky keymaps
    keymaps = [
      {
        mode = ["n" "x"];
        key = "y";
        action = "<Plug>(YankyYank)";
        options.desc = "Yank text";
      }
      {
        mode = ["n" "x"];
        key = "p";
        action = "<Plug>(YankyPutAfter)";
        options.desc = "Put yanked text after cursor";
      }
      {
        mode = ["n" "x"];
        key = "P";
        action = "<Plug>(YankyPutBefore)";
        options.desc = "Put yanked text before cursor";
      }
      {
        mode = ["n" "x"];
        key = "gp";
        action = "<Plug>(YankyGPutAfter)";
        options.desc = "Put yanked text after selection";
      }
      {
        mode = ["n" "x"];
        key = "gP";
        action = "<Plug>(YankyGPutBefore)";
        options.desc = "Put yanked text before selection";
      }
      {
        mode = "n";
        key = "]p";
        action = "<Plug>(YankyCycleForward)";
        options.desc = "Cycle yank history forward";
      }
      {
        mode = "n";
        key = "[p";
        action = "<Plug>(YankyCycleBackward)";
        options.desc = "Cycle yank history backward";
      }
    ];
  };
}
