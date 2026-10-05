{
  lib,
  pkgs,
  ...
}: {
  # llama.cpp — 本地推理（Vulkan / RDNA3），替代 Ollama
  environment.systemPackages = [pkgs.llama-cpp-vulkan];

  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp-vulkan;
    host = "127.0.0.1";
    port = 8080;
    # DynamicUser 的状态目录；把 .gguf 放到这里即可被 --models-dir 扫到
    modelsDir = "/var/lib/llama-cpp";
    modelsPreset = {
      "qwen3.8-27b" = {
        hf-repo = "unsloth/Qwen3.8-27B-GGUF";
        hf-file = "Qwen3.8-27B-UD-Q4_K_M.gguf";
        alias = "qwen3.8-27b";
        fit = "on";
        jinja = "on";
      };
    };
    extraFlags = [
      "-ngl"
      "999"
      "-fa"
      "on"
      "-c"
      "32768"
      "--jinja"
      "--fit"
      "on"
    ];
  };

  systemd.services.llama-cpp.serviceConfig = {
    # Vulkan 着色器需要可写可执行内存
    MemoryDenyWriteExecute = lib.mkForce false;
    SupplementaryGroups = [
      "render"
      "video"
    ];
  };

  systemd.services.llama-cpp.environment = {
    # 与 hardware 里 HIP_VISIBLE_DEVICES=1 一致：跳过核显
    GGML_VK_VISIBLE_DEVICES = "1";
    AMD_VULKAN_ICD = "RADV";
  };
}
