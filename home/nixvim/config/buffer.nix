{lib, ...}: {
  keymaps =
    [
      {
        key = "]b";
        action = "<cmd>bnext<cr>";
        options.desc = "Next buffer";
      }
      {
        key = "[b";
        action = "<cmd>bprevious<cr>";
        options.desc = "Previous buffer";
      }
      {
        key = "<S-l>";
        action = "<cmd>bnext<cr>";
        options.desc = "Next buffer";
      }
      {
        key = "<S-h>";
        action = "<cmd>bprevious<cr>";
        options.desc = "Previous buffer";
      }
      {
        key = "<leader>bb";
        action = "<cmd>b#<cr>";
        options.desc = "Alternate buffer";
      }
      {
        key = "<leader>bn";
        action = "<cmd>bnext<cr>";
        options.desc = "Next buffer";
      }
      {
        key = "<leader>bp";
        action = "<cmd>bprevious<cr>";
        options.desc = "Previous buffer";
      }
    ]
    ++ lib.genList (i: {
      key = "<leader>b${toString (i + 1)}";
      action = "<cmd>BufferLineGoToBuffer ${toString (i + 1)}<cr>";
      options.desc = "Go to buffer ${toString (i + 1)}";
    })
    9;
}
