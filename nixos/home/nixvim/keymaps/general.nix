{pkgs, ...}:
{
  programs.nixvim = {
    keymaps = [
      # 这里可以添加其他通用键盘映射
      # 例如：
      # {
      #   mode = "n";
      #   key = "<leader>w";
      #   action = ":w<CR>";
      #   options.desc = "Save file";
      # }
    ];
  };
}
