{ nixpkgs }:

system:
let
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  groups = import ../packages { inherit pkgs; };
in
{
  inherit pkgs groups;
  allPackages = groups.all;
}
