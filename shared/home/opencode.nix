{ ... }:

{
  programs.opencode = {
    enable = true;

    settings = {
      # 主题配置
      theme = "opencode";

      # 默认模型配置 (格式: provider/model-name)
      model = "anthropic/claude-3.7-sonnet";

      # 自动分享使用数据
      autoshare = false;

      # 自动更新检查
      autoupdate = true;
    };

    # 全局规则（AGENTS.md）
    rules = ''
      # 项目规则

      ## 代码风格
      - 遵循项目现有的代码风格
      - 保持代码简洁、可读、可维护
      - 使用有意义的变量名和函数名
      - 添加必要的注释说明

      ## 工作流程
      - 修改文件前先阅读相关代码
      - 理解修改的影响范围
      - 确保修改不破坏现有功能
      - 遵循测试驱动开发（TDD）原则

      ## Nix项目特殊规则
      - 所有配置更改必须添加到版本控制
      - 敏感数据必须使用sops-nix加密存储
      - 使用`nix flake check`验证配置语法
      - 使用`nix eval`评估配置正确性

      ## 安全要求
      - 绝不在代码中硬编码密码、API密钥等敏感信息
      - 使用环境变量或加密存储管理敏感数据
      - 遵循最小权限原则

      ## 文档规范
      - 重要修改需要更新相关文档
      - 保持README和注释的同步更新
      - 使用清晰的提交信息

      ## 测试要求
      - 提交前进行必要的测试验证
      - 使用dry-run模式测试构建
      - 清理测试生成的临时文件
    '';

    # 自定义命令
    commands = {
      # 快速格式化Nix代码
      format-nix = ''
        # Format Nix Code

        RUN nix fmt
        RUN git diff --stat
      '';

      # 快速检查flake
      check-flake = ''
        # Check Flake Configuration

        RUN nix flake check
        RUN nix eval .#nixosConfigurations.nixos.config.system.build.toplevel --dry-run
      '';

      # 更新flake inputs
      update-flake = ''
        # Update Flake Inputs

        RUN nix flake update
        RUN git status
      '';
    };
  };
}
