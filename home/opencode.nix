_: {
  programs.opencode = {
    enable = true;
    settings = {
      model = "llama.cpp/qwen3.8-27b";

      provider."llama.cpp" = {
        npm = "@ai-sdk/openai-compatible";
        name = "llama.cpp (local)";
        options = {
          baseURL = "http://127.0.0.1:8080/v1";
          apiKey = "local";
        };
        models."qwen3.8-27b" = {
          name = "Qwen3.8 27B";
          limit = {
            context = 32768;
            output = 4096;
          };
        };
      };
    };
  };
}
