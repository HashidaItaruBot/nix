{pkgs, ...}: {
  programs.helix = {
    enable = true;
    settings = {
      editor.line-number = "relative";
    };
  };
}
