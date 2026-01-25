{ pkgs, inputs, ... }: {
  imports = [
    inputs.nixvim.homeModules.nixvim # nixvim 模块
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true; # 设置 nvim 为系统默认编辑器
    globals.mapleader = " "; # leader键

    # 基础选项设置
    opts = {
      number = true;         # 显示行号
      relativenumber = true; # 相对行号
      shiftwidth = 2;        # 缩进
      smartindent = true;
      termguicolors = true;
      clipboard = "unnamedplus"; # 系统剪贴板
      updatetime = 300;
    };

    # 颜色主题
    colorschemes.catppuccin.enable = true;

    # 插件配置
    plugins = {
      lightline.enable = true; # 状态栏
      treesitter.enable = true; # 语法高亮
      telescope.enable = true; # 模糊搜索工具
      auto-save.enable = true; # 自动保存

      # 文件树
      neo-tree = { 
	enable = true; 
	close_if_last_window = true; # 如果只剩下 neo-tree 一个窗口就自动关闭
	filesystem = {
	  followCurrentFile.enable = true; # ⭐ 打开 neo-tree 时，自动定位到当前文件
	  hijack_netrw_behavior = "open_current"; # 如果文件被移动，自动更新树
	};
      };

      toggleterm = {
	enable = true;

	settings = {
	  size = 20;
	  open_mapping = "[[<c-/>]]"; # Ctrl + /
	  hide_numbers = true;
	  shade_terminals = true;
	  shading_factor = 2;
	  start_in_insert = true;
	  insert_mappings = true;
	  persist_size = true;
	  direction = "horizontal"; # horizontal | vertical | float | tab
	  close_on_exit = true;
	  shell = "${pkgs.zsh}/bin/zsh"; # macOS / nix-darwin 推荐
	};
      };

      mini-icons = {
        enable = true;
        mockDevIcons = true;
      };

      # LSP (语言服务器)
      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;    # Nix 语言支持
          pyright.enable = true; # Python 支持
          ts_ls.enable = true;   # TypeScript/JS 支持
        };
      };

      # 自动补全
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings.sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
      };
    };

    # 快捷键映射
    keymaps = [
      {
        mode = "n";
        key = "<leader>e";
        action = ":Neotree toggle<CR>";
        options.silent = true;
      }
    ];
  };
}
