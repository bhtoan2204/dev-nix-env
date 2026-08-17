{ pkgs }:

let
  inherit (pkgs) lib stdenv;

  dockerWrapper = pkgs.writeShellScriptBin "docker" ''
    export PODMAN_IGNORE_CGROUPSV1_WARNING=1
    export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
    exec ${pkgs.podman}/bin/podman "$@"
  '';

  dockerComposeWrapper = pkgs.writeShellScriptBin "docker-compose" ''
    export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
    exec ${pkgs.podman-compose}/bin/podman-compose "$@"
  '';
in
with pkgs;
[
  kubectl
  kubectx
  kubernetes-helm
  k9s
  opentofu
  awscli2
  grpcurl
  protobuf
  buf
  httpie
  redis
  postgresql
  mariadb.client
  stripe-cli
  inetutils
]
++ lib.optionals stdenv.hostPlatform.isLinux [
  podman
  podman-compose
  dockerWrapper
  dockerComposeWrapper
]
++ lib.optionals stdenv.hostPlatform.isDarwin [
  docker-client
]
