{
  plugins.which-key = {
    enable = true;

    settings = {
      preset = false;
      delay = 300;

      replace.desc = [
        ["<space>" "SPC"]
        ["<leader>" "SPC"]
      ];

      win = {
        border = "rounded";
        row = {__raw = "math.huge";};
        title = true;
        title_pos = "center";
        padding = [1 2];
      };

      spec = [
        {
          __unkeyed-1 = "<leader>a";
          group = "AI";
          icon = "󰚩 ";
        }
        {
          __unkeyed-1 = "<leader>b";
          group = "Buffer";
          icon = "󰓩 ";
        }
        {
          __unkeyed-1 = "<leader>f";
          group = "Find";
          icon = "󰈞 ";
        }
        {
          __unkeyed-1 = "<leader>g";
          group = "Git";
          icon = "󰊢 ";
        }
        {
          __unkeyed-1 = "<leader>l";
          group = "LSP";
          icon = "󰒕 ";
        }
        {
          __unkeyed-1 = "<leader>h";
          group = "Harpoon";
          icon = "󱡅 ";
        }
        {
          __unkeyed-1 = "<leader>m";
          group = "Metals";
          icon = "󰆧 ";
        }
        {
          __unkeyed-1 = "<leader>q";
          group = "Session";
          icon = "󰦛 ";
        }
        {
          __unkeyed-1 = "<leader>t";
          group = "Terminal";
          icon = " ";
        }
      ];
    };
  };
}
