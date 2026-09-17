{
  dependencies.lazygit.enable = true;

  plugins.lazygit = {
    enable = true;

    settings = {
      floating_window_scaling_factor = 0.9;
      floating_window_border_chars = [
        "╭"
        "─"
        "╮"
        "│"
        "╯"
        "─"
        "╰"
        "│"
      ];
    };
  };

  # toggleterm maps <Esc> in terminal mode to exit to Normal mode.
  # That steals Esc (and delays other keys) inside LazyGit — restore
  # pass-through so LazyGit keeps its own keybindings.
  extraConfigLua = ''
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "lazygit",
      callback = function(args)
        vim.keymap.set("t", "<Esc>", "<Esc>", {
          buffer = args.buf,
          silent = true,
          noremap = true,
          desc = "Pass Esc through to LazyGit",
        })
      end,
    })
  '';

  keymaps = [
    {
      mode = "n";
      key = "<leader>gg";
      action = "<cmd>LazyGit<CR>";
      options.desc = "LazyGit";
    }
  ];
}
