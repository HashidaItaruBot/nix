{pkgs, ...}: {
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "<leader>,";
        action = "<cmd>Telescope buffers sort_mru=true sort_lastused=true<CR>";
        options.desc = "Switch Buffer";
      }
      {
        mode = "n";
        key = "<leader>/";
        action = "<cmd>Telescope live_grep<CR>";
        options.desc = "Grep (Root Dir)";
      }
      {
        mode = "n";
        key = "<leader>:";
        action = "<cmd>Telescope command_history<CR>";
        options.desc = "Command History";
      }
      {
        mode = "n";
        key = "<leader><space>";
        action = "<cmd>Telescope find_files<CR>";
        options.desc = "Find Files (Root Dir)";
      }

      # f - Find
      {
        mode = "n";
        key = "<leader>fb";
        action = "<cmd>Telescope buffers sort_mru=true sort_lastused=true ignore_current_buffer=true<CR>";
        options.desc = "Buffers";
      }
      {
        mode = "n";
        key = "<leader>fB";
        action = "<cmd>Telescope buffers<CR>";
        options.desc = "Buffers (all)";
      }
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<CR>";
        options.desc = "Find Files (Root Dir)";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<cmd>Telescope git_files<CR>";
        options.desc = "Find Files (git-files)";
      }
      {
        mode = "n";
        key = "<leader>fr";
        action = "<cmd>Telescope oldfiles<CR>";
        options.desc = "Recent";
      }

      # g - Git
      {
        mode = "n";
        key = "<leader>gc";
        action = "<cmd>Telescope git_commits<CR>";
        options.desc = "Commits";
      }
      {
        mode = "n";
        key = "<leader>gs";
        action = "<cmd>Telescope git_status<CR>";
        options.desc = "Status";
      }
      {
        mode = "n";
        key = "<leader>gS";
        action = "<cmd>Telescope git_stash<CR>";
        options.desc = "Git Stash";
      }

      # s - Search
      {
        mode = "n";
        key = "<leader>s\"";
        action = "<cmd>Telescope registers<CR>";
        options.desc = "Registers";
      }
      {
        mode = "n";
        key = "<leader>s/";
        action = "<cmd>Telescope search_history<CR>";
        options.desc = "Search History";
      }
      {
        mode = "n";
        key = "<leader>sa";
        action = "<cmd>Telescope autocommands<CR>";
        options.desc = "Autocommands";
      }
      {
        mode = "n";
        key = "<leader>sb";
        action = "<cmd>Telescope current_buffer_fuzzy_find<CR>";
        options.desc = "Current Buffer";
      }
      {
        mode = "n";
        key = "<leader>sc";
        action = "<cmd>Telescope command_history<CR>";
        options.desc = "Command History";
      }
      {
        mode = "n";
        key = "<leader>sC";
        action = "<cmd>Telescope commands<CR>";
        options.desc = "Commands";
      }
      {
        mode = "n";
        key = "<leader>sd";
        action = "<cmd>Telescope diagnostics<CR>";
        options.desc = "Diagnostics";
      }
      {
        mode = "n";
        key = "<leader>sg";
        action = "<cmd>Telescope live_grep<CR>";
        options.desc = "Live Grep";
      }
      {
        mode = "n";
        key = "<leader>sh";
        action = "<cmd>Telescope help_tags<CR>";
        options.desc = "Help Tags";
      }
      {
        mode = "n";
        key = "<leader>sH";
        action = "<cmd>Telescope highlights<CR>";
        options.desc = "Highlights";
      }
      {
        mode = "n";
        key = "<leader>sj";
        action = "<cmd>Telescope jumplist<CR>";
        options.desc = "Jumplist";
      }
      {
        mode = "n";
        key = "<leader>sk";
        action = "<cmd>Telescope keymaps<CR>";
        options.desc = "Keymaps";
      }
      {
        mode = "n";
        key = "<leader>sl";
        action = "<cmd>Telescope loclist<CR>";
        options.desc = "Location List";
      }
      {
        mode = "n";
        key = "<leader>sM";
        action = "<cmd>Telescope man_pages<CR>";
        options.desc = "Man Pages";
      }
      {
        mode = "n";
        key = "<leader>sm";
        action = "<cmd>Telescope marks<CR>";
        options.desc = "Marks";
      }
      {
        mode = "n";
        key = "<leader>so";
        action = "<cmd>Telescope vim_options<CR>";
        options.desc = "Vim Options";
      }
      {
        mode = "n";
        key = "<leader>sR";
        action = "<cmd>Telescope resume<CR>";
        options.desc = "Resume";
      }
      {
        mode = "n";
        key = "<leader>sq";
        action = "<cmd>Telescope quickfix<CR>";
        options.desc = "Quickfix";
      }
      {
        mode = "n";
        key = "<leader>sw";
        action = "<cmd>Telescope grep_string<CR>";
        options.desc = "Word (Root Dir)";
      }
      {
        mode = "n";
        key = "<leader>ss";
        action = "<cmd>Telescope lsp_document_symbols<CR>";
        options.desc = "Goto Symbol";
      }
      {
        mode = "n";
        key = "<leader>sS";
        action = "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>";
        options.desc = "Goto Symbol (Workspace)";
      }

      # UI
      {
        mode = "n";
        key = "<leader>uC";
        action = "<cmd>Telescope colorscheme enable_preview=true<CR>";
        options.desc = "Colorscheme with Preview";
      }
    ];
  };
}
