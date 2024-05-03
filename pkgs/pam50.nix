{ pkgs, rSuggestsPackages ? [ ] }:
let
  name = "pam50";

  version = builtins.elemAt (builtins.split ": "
    (builtins.elemAt (builtins.split "\n" (builtins.readFile (../DESCRIPTION)))
      4)) 2;

  rPackages = with pkgs.rPackages;
    [ matrixStats impute logger tidyr ] ++ rSuggestsPackages;

in pkgs.rPackages.buildRPackage {
  inherit name version;
  src = ../.;
  propagatedBuildInputs = rPackages;
}
