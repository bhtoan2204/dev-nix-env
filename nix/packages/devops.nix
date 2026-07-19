{ pkgs }:

let
  dockerWrapper = pkgs.writeShellScriptBin "docker" ''
    export PODMAN_IGNORE_CGROUPSV1_WARNING=1
    export XDG_CONFIG_HOME="$HOME/.config"
    exec ${pkgs.podman}/bin/podman "$@"
  '';

  dockerComposeWrapper = pkgs.writeShellScriptBin "docker-compose" ''
    export XDG_CONFIG_HOME="$HOME/.config"
    exec ${pkgs.podman-compose}/bin/podman-compose "$@"
  '';
in
with pkgs; [
  podman
  podman-compose
  nodejs_22
  stripe-cli
  inetutils

  dockerWrapper
  dockerComposeWrapper
]
