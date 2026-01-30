return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- 确保 mason 已关闭
      mason = false,
      -- 在这里列出你想启用的服务器（前提是你已通过 Nix 安装了它们）
      servers = {
        lua_ls = {},
        pyright = {},
        -- 即使 opts.mason 为 false，LazyVim 仍会尝试根据此列表配置服务器
      },
    },
  },
}
