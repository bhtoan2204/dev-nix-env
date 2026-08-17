{ pkgs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/system.nix
  ];

  networking.hostName = "nixos";

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  # Keep this at the release used for the first installation.
  system.stateVersion = "24.11";
}
