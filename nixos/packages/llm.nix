# 本地 AI 服务模块（可选）
# 来源: XNM1/linux-nixos-hyprland-config-dotfiles nixos/llm.nix
# 注释掉 nixos/packages/default.nix 中的 ./llm.nix 即可禁用全部
{
  config,
  pkgs,
  ...
}:
{
  # ---- Ollama 本地 LLM 服务 ----
  services.ollama = {
    enable = true;
    # AMD GPU，使用 CPU 版（如需 ROCm 加速可设为 pkgs.ollama-rocm）
    package = pkgs.ollama;
    # 预加载模型（首次启动自动下载，约需 10-30GB）
    loadModels = [
      "gemma3:4b"         # 轻量通用模型
      "qwen3:14b"          # 中文优化模型
      "nomic-embed-text"   # 文本嵌入
    ];
    # 如果模型列表和本地不一致，自动清理或下载同步
    # syncModels = true;
  };

  # ---- SearXNG 隐私搜索引擎 ----
  services.searx = {
    enable = true;
    settings = {
      server = {
        port = 7777;
        bind_address = "127.0.0.1";
        # 密钥须在环境文件中设置: SEARX_SECRET_KEY
        secret_key = "@SEARX_SECRET_KEY@";
      };
      search = {
        formats = [ "html" "json" ];
      };
    };
    environmentFile = "${config.users.users.zhaochanglong.home}/.config/.env.searxng";
  };

  # ---- AI CLI 工具 ----
  environment.systemPackages = with pkgs; [
    aichat        # ChatGPT-like CLI
    fabric-ai     # AI prompt/workflow toolkit
    oterm         # TUI LLM 客户端
  ];
}
