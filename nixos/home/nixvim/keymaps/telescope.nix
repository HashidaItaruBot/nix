{pkgs, ...}:
{
  programs.nixvim = {
    keymaps = [
      # 快捷跳转
      {
        mode = "n";
        key = "<leader>,";
        action = "buffers sort_mru=true sort_lastused=true";
        options.desc = "Switch Buffer";
      }
      {
        mode = "n";
        key = "<leader>/";
        action = "live_grep";
        options.desc = "Grep (Root Dir)";
      }
      {
        mode = "n";
        key = "<leader>:";
        action = "command_history";
        options.desc = "Command History";
      }
      {
        mode = "n";
        key = "<leader><space>";
        action = "find_files";
        options.desc = "Find Files (Root Dir)";
      }

      # f - Find 模块
      {
        mode = "n";
        key = "<leader>fb";
        action = "buffers sort_mru=true sort_lastused=true ignore_current_buffer=true";
        options.desc = "Buffers";
      }
      {
        mode = "n";
        key = "<leader>fB";
        action = "buffers";
        options.desc = "Buffers (all)";
      }
      {
        mode = "n";
        key = "<leader>ff";
        action = "find_files";
        options.desc = "Find Files (Root Dir)";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "git_files";
        options.desc = "Find Files (git-files)";
      }
      {
        mode = "n";
        key = "<leader>fr";
        action = "oldfiles";
        options.desc = "Recent";
      }

      # g - Git 模块
      {
        mode = "n";
        key = "<leader>gc";
        action = "git_commits";
        options.desc = "Commits";
      }
      {
        mode = "n";
        key = "<leader>gs";
        action = "git_status";
        options.desc = "Status";
      }
      {
        mode = "n";
        key = "<leader>gS";
        action = "git_stash";
        options.desc = "Git Stash";
      }

      # s - Search 模块
      {
        mode = "n";
        key = "<leader>s\"";
        action = "registers";
      }
      {
        mode = "n";
        key = "<leader>s/";
        action = "search_history";
      }
      {
        mode = "n";
        key = "<leader>sa";
        action = "autocommands";
      }
      {
        mode = "n";
        key = "<leader>sb";
        action = "current_buffer_fuzzy_find";
      }
      {
        mode = "n";
        key = "<leader>sc";
        action = "command_history";
      }
      {
        mode = "n";
        key = "<leader>sC";
        action = "commands";
      }
      {
        mode = "n";
        key = "<leader>sd";
        action = "diagnostics";
      }
      {
        mode = "n";
        key = "<leader>sg";
        action = "live_grep";
      }
      {
        mode = "n";
        key = "<leader>sh";
        action = "help_tags";
      }
      {
        mode = "n";
        key = "<leader>sH";
        action = "highlights";
      }
      {
        mode = "n";
        key = "<leader>sj";
        action = "jumplist";
      }
      {
        mode = "n";
        key = "<leader>sk";
        action = "keymaps";
      }
      {
        mode = "n";
        key = "<leader>sl";
        action = "loclist";
      }
      {
        mode = "n";
        key = "<leader>sM";
        action = "man_pages";
      }
      {
        mode = "n";
        key = "<leader>sm";
        action = "marks";
      }
      {
        mode = "n";
        key = "<leader>so";
        action = "vim_options";
      }
      {
        mode = "n";
        key = "<leader>sR";
        action = "resume";
      }
      {
        mode = "n";
        key = "<leader>sq";
        action = "quickfix";
      }
      {
        mode = "n";
        key = "<leader>sw";
        action = "grep_string";
        options.desc = "Word (Root Dir)";
      }
      {
        mode = "n";
        key = "<leader>ss";
        action = "lsp_document_symbols";
        options.desc = "Goto Symbol";
      }
      {
        mode = "n";
        key = "<leader>sS";
        action = "lsp_dynamic_workspace_symbols";
        options.desc = "Goto Symbol (Workspace)";
      }

      # UI 模块
      {
        mode = "n";
        key = "<leader>uC";
        action = "colorscheme enable_preview=true";
        options.desc = "Colorscheme with Preview";
      }
    ];
  };
}
