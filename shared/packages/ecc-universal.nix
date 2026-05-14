{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "ecc-universal";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "affaan-m";
    repo = "everything-claude-code";
    rev = "v${version}";
    hash = "sha256-vzlPCasQIl7WWgtpUoeVu0Q9lAHKmahFp0oi4542weo=";
  };

  npmDepsHash = "sha256-e4g6ZPzcEJ8piRVnmLcwrdiv2FMqH/bNjOvZn0el+f4=";
  npmPackFlags = [ "--ignore-scripts" ];

  dontNpmBuild = true;

  meta = with lib; {
    description = "Complete collection of battle-tested Claude Code configs — agents, skills, hooks, rules, and legacy command shims";
    homepage = "https://github.com/affaan-m/everything-claude-code";
    license = licenses.mit;
    mainProgram = "ecc";
  };
}
