{pkgs, ...}: {
  programs.nixvim = {
    plugins.illuminate = {
      enable = true;
      settings = {
        delay = 200;
        large_file_cutoff = 2000;
        large_file_overrides = {
          providers = ["lsp"];
        };
        min_count_to_highlight = 1;
        under_cursor = true;
      };
    };
  };
}
