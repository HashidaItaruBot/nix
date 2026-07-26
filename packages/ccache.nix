{...}: {
  programs.ccache = {
    enable = true;
    cacheDir = "/home/zhaochanglong/.cache/ccache";
    owner = "zhaochanglong";
    group = "users";
  };
}
