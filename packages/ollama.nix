{pkgs, ...}: {
  # Ollama — 本地大模型推理（ROCm，走独立显卡）
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    environmentVariables = {
      ROCR_VISIBLE_DEVICES = "1";
      HIP_VISIBLE_DEVICES = "1";
    };
  };
}
