{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.todo-comments = {
      enable = true;
      settings = {
        keywords = {
          FIX = {
            icon = " ";
            color = "error";
            alt = [ "FIXME" "BUG" "FIXIT" "ISSUE" ];
          };
          TODO = {
            icon = " ";
            color = "info";
          };
          HACK = {
            icon = " ";
            color = "warning";
          };
          WARN = {
            icon = " ";
            color = "warning";
            alt = [ "WARNING" "XXX" ];
          };
          PERF = {
            icon = " ";
            color = "default";
            alt = [ "OPTIM" "PERFORMANCE" "OPTIMIZE" ];
          };
          NOTE = {
            icon = " ";
            color = "hint";
            alt = [ "INFO" ];
          };
          TEST = {
            icon = "⏲ ";
            color = "test";
            alt = [ "TESTING" "PASSED" "FAILED" ];
          };
        };
      };
    };

    # Todo-comments keymaps
    keymaps = [
      {
        mode = "n";
        key = "]t";
        action.__raw = ''
          function()
            require("todo-comments").jump_next()
          end
        '';
        options.desc = "Next Todo Comment";
      }
      {
        mode = "n";
        key = "[t";
        action.__raw = ''
          function()
            require("todo-comments").jump_prev()
          end
        '';
        options.desc = "Previous Todo Comment";
      }
      {
        mode = "n";
        key = "<leader>xt";
        action = "<cmd>Trouble todo toggle<cr>";
        options.desc = "Todo (Trouble)";
      }
      {
        mode = "n";
        key = "<leader>xT";
        action = "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>";
        options.desc = "Todo/Fix/Fixme (Trouble)";
      }
    ];
  };
}