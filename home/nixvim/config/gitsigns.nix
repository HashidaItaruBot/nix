{
  plugins.gitsigns = {
    enable = true;

    settings = {
      signcolumn = true;
      current_line_blame = false;

      signs = {
        add.text = "│";
        change.text = "│";
        delete.text = "_";
        topdelete.text = "‾";
        changedelete.text = "~";
        untracked.text = "┆";
      };

      watch_gitdir.follow_files = true;

      on_attach = ''
        function(bufnr)
          local gitsigns = require("gitsigns")

          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, {
              buffer = bufnr,
              desc = desc,
            })
          end

          -- Navigation
          map("n", "]h", function()
            if vim.wo.diff then
              vim.cmd.normal({ "]c", bang = true })
            else
              gitsigns.nav_hunk("next")
            end
          end, "Next hunk")

          map("n", "[h", function()
            if vim.wo.diff then
              vim.cmd.normal({ "[c", bang = true })
            else
              gitsigns.nav_hunk("prev")
            end
          end, "Previous hunk")

          -- Actions
          map("n", "<leader>gs", gitsigns.stage_hunk, "Stage hunk")
          map("n", "<leader>gr", gitsigns.reset_hunk, "Reset hunk")
          map("v", "<leader>gs", function()
            gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, "Stage hunk")
          map("v", "<leader>gr", function()
            gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, "Reset hunk")

          map("n", "<leader>gS", gitsigns.stage_buffer, "Stage buffer")
          map("n", "<leader>gR", gitsigns.reset_buffer, "Reset buffer")
          map("n", "<leader>gu", gitsigns.undo_stage_hunk, "Undo stage hunk")
          map("n", "<leader>gp", gitsigns.preview_hunk, "Preview hunk")
          map("n", "<leader>gi", gitsigns.preview_hunk_inline, "Preview hunk inline")
          map("n", "<leader>gb", function()
            gitsigns.blame_line({ full = true })
          end, "Blame line")
          map("n", "<leader>gd", gitsigns.diffthis, "Diff this")
          map("n", "<leader>gt", gitsigns.toggle_current_line_blame, "Toggle line blame")

          -- Text object
          map({ "o", "x" }, "ih", gitsigns.select_hunk, "Select hunk")
        end
      '';
    };
  };
}
