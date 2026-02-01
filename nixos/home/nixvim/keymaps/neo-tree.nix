{pkgs, ...}:
{
  programs.nixvim = {
    keymaps = [
      # NeoTree Root Dir
      {
        mode = "n";
        key = "<leader>fe";
        action = ''<cmd>lua require("neo-tree.command").execute({ toggle = true, dir = vim.fn.getcwd() })<cr>'';
        options.desc = "Explorer NeoTree (Root Dir)";
      }
      # NeoTree CWD
      {
        mode = "n";
        key = "<leader>fE";
        action = ''<cmd>lua require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })<cr>'';
        options.desc = "Explorer NeoTree (cwd)";
      }
      # 别名映射 (remap = true)
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
      # Git Explorer
      {
        mode = "n";
        key = "<leader>ge";
        action = ''<cmd>lua require("neo-tree.command").execute({ source = "git_status", toggle = true })<cr>'';
        options.desc = "Git Explorer";
      }
      # Buffer Explorer
      {
        mode = "n";
        key = "<leader>be";
        action = ''<cmd>lua require("neo-tree.command").execute({ source = "buffers", toggle = true })<cr>'';
        options.desc = "Buffer Explorer";
      }
    ];
  };
}
