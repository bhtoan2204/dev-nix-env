{ username, ... }:

{
  networking.hostName = "macos";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;
  users.users.${username}.home = "/Users/${username}";
  system.primaryUser = username;

  # See `darwin-rebuild changelog` before changing this value.
  system.stateVersion = 6;
}
