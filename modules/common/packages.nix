{ lib, pkgs, ... }:

let
  groups = import ../../packages { inherit pkgs; };
  managedByHomeManager = with pkgs; [
    git
    neovim
    tmux
    fzf
    zoxide
    direnv
    nix-direnv
  ];
in
{
  home.packages = lib.filter (package: !(lib.elem package managedByHomeManager)) groups.all;

  home.sessionPath = [
    "$HOME/go/bin"
    "$HOME/.local/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less -FR";
    GOPATH = "$HOME/go";
  };
}
