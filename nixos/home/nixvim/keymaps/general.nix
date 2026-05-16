{pkgs, ...}: {
  programs.nixvim = {
    keymaps = [
      # Better window navigation
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
        options.desc = "Go to left window";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w>j";
        options.desc = "Go to lower window";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w>k";
        options.desc = "Go to upper window";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
        options.desc = "Go to right window";
      }

      # Resize windows
      {
        mode = "n";
        key = "<C-Up>";
        action = "<cmd>resize +2<cr>";
        options.desc = "Increase window height";
      }
      {
        mode = "n";
        key = "<C-Down>";
        action = "<cmd>resize -2<cr>";
        options.desc = "Decrease window height";
      }
      {
        mode = "n";
        key = "<C-Left>";
        action = "<cmd>vertical resize -2<cr>";
        options.desc = "Decrease window width";
      }
      {
        mode = "n";
        key = "<C-Right>";
        action = "<cmd>vertical resize +2<cr>";
        options.desc = "Increase window width";
      }

      # Move lines
      {
        mode = "n";
        key = "<A-j>";
        action = "<cmd>m .+1<cr>==";
        options.desc = "Move line down";
      }
      {
        mode = "n";
        key = "<A-k>";
        action = "<cmd>m .-2<cr>==";
        options.desc = "Move line up";
      }
      {
        mode = "v";
        key = "<A-j>";
        action = ":m '>+1<cr>gv=gv";
        options.desc = "Move selection down";
      }
      {
        mode = "v";
        key = "<A-k>";
        action = ":m '<-2<cr>gv=gv";
        options.desc = "Move selection up";
      }

      # Better paste
      {
        mode = "v";
        key = "p";
        action = "\"_dP";
        options.desc = "Paste without yanking";
      }

      # Clear search highlight
      {
        mode = "n";
        key = "<Esc>";
        action = "<cmd>noh<cr><Esc>";
        options.desc = "Clear search highlight";
      }

      # Save file
      {
        mode = ["i" "n" "v"];
        key = "<C-s>";
        action = "<cmd>w<cr>";
        options.desc = "Save file";
      }

      # Quit
      {
        mode = "n";
        key = "<leader>qq";
        action = "<cmd>qa<cr>";
        options.desc = "Quit all";
      }

      # Terminal
      {
        mode = "n";
        key = "<leader>ft";
        action = "<cmd>terminal<cr>";
        options.desc = "Open terminal";
      }

      # Lazy
      {
        mode = "n";
        key = "<leader>l";
        action = "<cmd>Lazy<cr>";
        options.desc = "Lazy";
      }

      # Mason
      {
        mode = "n";
        key = "<leader>cm";
        action = "<cmd>Mason<cr>";
        options.desc = "Mason";
      }

      # Split
      {
        mode = "n";
        key = "<leader>-";
        action = "<C-W>s";
        options.desc = "Split window below";
      }
      {
        mode = "n";
        key = "<leader>|";
        action = "<C-W>v";
        options.desc = "Split window right";
      }

      # Quickfix
      {
        mode = "n";
        key = "<leader>xq";
        action = "<cmd>copen<cr>";
        options.desc = "Open quickfix";
      }
      {
        mode = "n";
        key = "<leader>xl";
        action = "<cmd>lopen<cr>";
        options.desc = "Open location list";
      }
    ];
  };
}
