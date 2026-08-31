{
  plugins.gitsigns = {
    enable = true;
    settings.signs = {
      add.text = "+";
      change.text = "~";
      changedelete.text = "~";
      delete.text = "_";
      topdelete.text = "‾";
      untracked.text = "┆";
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "]c";
      action.__raw = ''
        function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            require('gitsigns').nav_hunk 'next'
          end
        end
      '';
      options.desc = "Jump to next git [c]hange";
    }
    {
      mode = "n";
      key = "[c";
      action.__raw = ''
        function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            require('gitsigns').nav_hunk 'prev'
          end
        end
      '';
      options.desc = "Jump to previous git [c]hange";
    }
    {
      mode = "n";
      key = "<leader>hs";
      action.__raw = "function() require('gitsigns').stage_hunk() end";
      options.desc = "git [s]tage hunk";
    }
    {
      mode = "n";
      key = "<leader>hr";
      action.__raw = "function() require('gitsigns').reset_hunk() end";
      options.desc = "git [r]eset hunk";
    }
    {
      mode = "n";
      key = "<leader>hp";
      action.__raw = "function() require('gitsigns').preview_hunk() end";
      options.desc = "git [p]review hunk";
    }
    {
      mode = "n";
      key = "<leader>hb";
      action.__raw = "function() require('gitsigns').blame_line({ full = true }) end";
      options.desc = "git [b]lame line";
    }
    {
      mode = "n";
      key = "<leader>tb";
      action.__raw = "function() require('gitsigns').toggle_current_line_blame() end";
      options.desc = "[T]oggle git show [b]lame line";
    }
  ];
}
