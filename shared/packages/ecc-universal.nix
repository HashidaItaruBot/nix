{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "ecc-universal";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "affaan-m";
    repo = "everything-claude-code";
    rev = "v${version}";
    hash = "sha256-ocCwYArThCTVDHgmV//l3tMQtu6kJB10aic5QD2BDbQ=";
  };

  npmDepsHash = "sha256-jnM0p07SDxxgDYoXYCuIzoPFID6qJ9jqbwpfcEPLRPU=";
  npmPackFlags = [ "--ignore-scripts" ];

  dontNpmBuild = true;

  meta = with lib; {
    description = "Complete collection of battle-tested Claude Code configs — agents, skills, hooks, rules, and legacy command shims";
    homepage = "https://github.com/affaan-m/everything-claude-code";
    license = licenses.mit;
    mainProgram = "ecc";
  };
}
