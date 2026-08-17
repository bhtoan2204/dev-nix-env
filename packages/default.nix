{ pkgs }:

let
  groups = {
    base = import ./base.nix { inherit pkgs; };
    build = import ./build.nix { inherit pkgs; };
    go = import ./go.nix { inherit pkgs; };
    rust = import ./rust.nix { inherit pkgs; };
    node = import ./node.nix { inherit pkgs; };
    devops = import ./devops.nix { inherit pkgs; };
  };
in
groups // { all = pkgs.lib.concatLists (builtins.attrValues groups); }
