{ username, ... }:

{
  imports = [
    ./packages.nix
    ./git.nix
    ./shell.nix
    ./tmux.nix
    ./neovim.nix
  ];

  home.username = username;
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
