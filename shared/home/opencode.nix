{ pkgs, ... }:

{
  programs.opencode = {
    enable = true;

    settings = {
      # 默认模型配置
      model = "openai/glm-5";

      # Agent配置
      agents = {
        coder = {
          model = "openai/glm-5";
          maxTokens = 8192;
        };
        task = {
          model = "openai/glm-5";
          maxTokens = 4096;
        };
        title = {
          model = "openai/glm-5";
          maxTokens = 80;
        };
      };

      # 自动压缩长对话
      autoCompact = true;

      # Shell配置
      shell = {
        path = "/bin/bash";
        args = [ "-l" ];
      };
    };

    # 自定义规则（AGENTS.md）
    rules = ''
      # 项目规则

      ## 代码风格
      - 遵循项目现有的代码风格
      - 保持代码简洁、可读

      ## 工作流程
      - 修改文件前先阅读相关代码
      - 确保修改不破坏现有功能
    '';
  };
}
