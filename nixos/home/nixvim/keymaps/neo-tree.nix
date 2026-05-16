{pkgs, ...}: {
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "<leader>fe";
        action.__raw = ''
          function()
            local root = vim.fs.root(0, ".git") or vim.fn.getcwd()
            require("neo-tree.command").execute({ toggle = true, dir = root })
          end
        '';
        options.desc = "Explorer NeoTree (Root Dir)";
      }
      {
        mode = "n";
        key = "<leader>fE";
        action = ''<cmd>lua require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })<cr>'';
        options.desc = "Explorer NeoTree (cwd)";
      }
      {
        mode = "n";
        key = "<leader>e";
        action = "<leader>fe";
        options = {
          desc = "Explorer NeoTree (Root Dir)";
          remap = true;
        };
      }
      {
        mode = "n";
        key = "<leader>E";
        action = "<leader>fE";
        options = {
          desc = "Explorer NeoTree (cwd)";
          remap = true;
        };
      }
      {
        mode = "n";
        key = "<leader>ge";
        action = ''<cmd>lua require("neo-tree.command").execute({ source = "git_status", toggle = true })<cr>'';
        options.desc = "Git Explorer";
      }
      {
        mode = "n";
        key = "<leader>be";
        action = ''<cmd>lua require("neo-tree.command").execute({ source = "buffers", toggle = true })<cr>'';
        options.desc = "Buffer Explorer";
      }
    ];
  };
}
