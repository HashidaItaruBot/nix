{
  # Detect tab/space width from the current file contents.
  plugins.guess-indent = {
    enable = true;
    settings = {
      auto_cmd = true;
      # Prefer project .editorconfig when present.
      override_editorconfig = false;
    };
  };
}
