{pkgs, ...}: {
  programs.sbt = {
    enable = true;
    package = pkgs.sbt.override {jre = pkgs.openjdk8;};
  };
}
