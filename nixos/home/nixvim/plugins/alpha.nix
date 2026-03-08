{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.alpha = {
      enable = true;
      settings.layout = [
        {
          type = "padding";
          val = 2;
        }
        {
          type = "text";
          val = [
            "                                                     "
            "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ "
            "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ "
            "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ "
            "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ "
            "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ "
            "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ "
            "                                                     "
          ];
          opts = {
            hl = "AlphaHeader";
            position = "center";
          };
        }
        {
          type = "padding";
          val = 2;
        }
        {
          type = "group";
          val = [
            {
              type = "button";
              val = "  New File  ";
              on_press.__raw = "function() vim.cmd[[ene]] end";
              opts = {
                shortcut = "n";
                hl = "AlphaButton";
                hl_shortcut = "AlphaShortcut";
                position = "center";
                align_shortcut = "right";
              };
            }
            {
              type = "button";
              val = "  Find File  ";
              on_press.__raw = "function() vim.cmd[[Telescope find_files]] end";
              opts = {
                shortcut = "f";
                hl = "AlphaButton";
                hl_shortcut = "AlphaShortcut";
                position = "center";
                align_shortcut = "right";
              };
            }
            {
              type = "button";
              val = "  Recent Files  ";
              on_press.__raw = "function() vim.cmd[[Telescope oldfiles]] end";
              opts = {
                shortcut = "r";
                hl = "AlphaButton";
                hl_shortcut = "AlphaShortcut";
                position = "center";
                align_shortcut = "right";
              };
            }
            {
              type = "button";
              val = "  Find Word  ";
              on_press.__raw = "function() vim.cmd[[Telescope live_grep]] end";
              opts = {
                shortcut = "g";
                hl = "AlphaButton";
                hl_shortcut = "AlphaShortcut";
                position = "center";
                align_shortcut = "right";
              };
            }
            {
              type = "button";
              val = "  LazyGit  ";
              on_press.__raw = "function() vim.cmd[[LazyGit]] end";
              opts = {
                shortcut = "G";
                hl = "AlphaButton";
                hl_shortcut = "AlphaShortcut";
                position = "center";
                align_shortcut = "right";
              };
            }
            {
              type = "button";
              val = "  Quit  ";
              on_press.__raw = "function() vim.cmd[[qa]] end";
              opts = {
                shortcut = "q";
                hl = "AlphaButton";
                hl_shortcut = "AlphaShortcut";
                position = "center";
                align_shortcut = "right";
              };
            }
          ];
        }
        {
          type = "padding";
          val = 2;
        }
        {
          type = "text";
          val.__raw = ''"  Neovim v" .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch  '';
          opts = {
            hl = "AlphaFooter";
            position = "center";
          };
        }
      ];
    };
  };
}