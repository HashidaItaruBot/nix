{pkgs, ...}: {
  programs.nixvim = {
    keymaps = [
      # LSP相关键盘映射
      {
        mode = "n";
        key = "gd";
        action = "<cmd>lua vim.lsp.buf.definition()<CR>";
        options.desc = "跳转到定义";
      }
      {
        mode = "n";
        key = "gD";
        action = "<cmd>lua vim.lsp.buf.type_definition()<CR>";
        options.desc = "跳转到类型定义";
      }
      {
        mode = "n";
        key = "K";
        action = "<cmd>lua vim.lsp.buf.hover()<CR>";
        options.desc = "显示悬停信息";
      }
      {
        mode = "n";
        key = "gi";
        action = "<cmd>lua vim.lsp.buf.implementation()<CR>";
        options.desc = "跳转到实现";
      }
      {
        mode = "n";
        key = "gr";
        action = "<cmd>lua vim.lsp.buf.references()<CR>";
        options.desc = "跳转到引用";
      }
      {
        mode = "n";
        key = "<leader>rn";
        action = "<cmd>lua vim.lsp.buf.rename()<CR>";
        options.desc = "重命名符号";
      }
      {
        mode = "n";
        key = "<leader>ca";
        action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
        options.desc = "代码操作";
      }
      {
        mode = "n";
        key = "<leader>f";
        action = "<cmd>lua vim.lsp.buf.format({ async = true })<CR>";
        options.desc = "格式化代码";
      }
      {
        mode = "n";
        key = "<leader>d";
        action = "<cmd>lua vim.diagnostic.open_float()<CR>";
        options.desc = "显示诊断信息";
      }
      {
        mode = "n";
        key = "[d";
        action = "<cmd>lua vim.diagnostic.goto_prev()<CR>";
        options.desc = "上一个诊断";
      }
      {
        mode = "n";
        key = "]d";
        action = "<cmd>lua vim.diagnostic.goto_next()<CR>";
        options.desc = "下一个诊断";
      }
      {
        mode = "n";
        key = "<leader>q";
        action = "<cmd>lua vim.diagnostic.setloclist()<CR>";
        options.desc = "诊断列表";
      }
      # Telescope LSP集成
      {
        mode = "n";
        key = "<leader>ls";
        action = "<cmd>Telescope lsp_document_symbols<CR>";
        options.desc = "文档符号";
      }
      {
        mode = "n";
        key = "<leader>lS";
        action = "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>";
        options.desc = "工作区符号";
      }
      {
        mode = "n";
        key = "<leader>ld";
        action = "<cmd>Telescope diagnostics<CR>";
        options.desc = "诊断信息";
      }
      {
        mode = "n";
        key = "<leader>li";
        action = "<cmd>Telescope lsp_implementations<CR>";
        options.desc = "实现";
      }
      {
        mode = "n";
        key = "<leader>lr";
        action = "<cmd>Telescope lsp_references<CR>";
        options.desc = "引用";
      }
    ];
  };
}
