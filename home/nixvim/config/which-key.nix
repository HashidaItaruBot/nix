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
          __unkeyed-1 = "<leader>f";
          group = "Find";
          icon = "󰈞 ";
        }
        {
          __unkeyed-1 = "<leader>g";
          group = "Git";
          icon = "󰊢 ";
        }
      ];
    };
  };
}
