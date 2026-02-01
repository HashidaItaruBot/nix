_:
{
  programs.aider-chat.enable = true;
  programs.aider-chat.settings = {
    architect = true;
    auto-accept-architect = false;
    cache-prompts = true;
    check-model-accepts-settings = false;
    dark-mode = true;
    dirty-commits = false;
    lint = true;
    show-model-warnings = false;
    verify-ssl = false;
  };
}
