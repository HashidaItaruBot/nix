return {
  -- 禁用 Mason 核心插件
  { "mason-org/mason.nvim", enabled = false },
  -- 禁用 Mason 与 LSPConfig 的桥接插件
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  -- 如果你使用了格式化或诊断，也可能需要禁用以下插件
  { "jay-babu/mason-null-ls.nvim", enabled = false },
  { "jay-babu/mason-nvim-dap.nvim", enabled = false },
}
