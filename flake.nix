{
  description = "Go and DevOps development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    in {
      packages.${system}.default = pkgs.buildEnv {
        name = "dev-global-env";
        paths = [
          pkgs.git pkgs.gh pkgs.curl pkgs.wget pkgs.gnumake pkgs.tree pkgs.htop pkgs.tmux pkgs.screen pkgs.unzip pkgs.zip pkgs.entr pkgs.jq pkgs.yq-go
          pkgs.ripgrep pkgs.fd pkgs.bat pkgs.fzf
          pkgs.go pkgs.gopls pkgs.golangci-lint pkgs.grpcurl pkgs.mockgen pkgs.protoc-gen-go pkgs.protoc-gen-go-grpc pkgs.gotools pkgs.gotests pkgs.go-migrate
          pkgs.protobuf pkgs.cmake pkgs.ninja pkgs.pkg-config pkgs.autoconf pkgs.autoconf-archive pkgs.automake pkgs.libtool pkgs.m4 pkgs.bison
          pkgs.podman pkgs.podman-compose pkgs.nodejs_22 pkgs.stripe-cli pkgs.inetutils
          
          # Wrapper docker cho Global profile
          (pkgs.writeShellScriptBin "docker" ''
            export PODMAN_IGNORE_CGROUPSV1_WARNING=1
            export XDG_CONFIG_HOME="$HOME/.config"
            exec ${pkgs.podman}/bin/podman "$@"
          '')
          # Wrapper docker-compose cho Global profile
          (pkgs.writeShellScriptBin "docker-compose" ''
            export XDG_CONFIG_HOME="$HOME/.config"
            exec ${pkgs.podman-compose}/bin/podman-compose "$@"
          '')
          (pkgs.python3.withPackages (ps: with ps; [ ps.pip ps.black ps.autopep8 ps.pycodestyle ]))
        ];
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          git gh curl wget gnumake tree htop tmux screen unzip zip entr jq yq-go
          ripgrep fd bat fzf
          go gopls golangci-lint grpcurl mockgen protoc-gen-go protoc-gen-go-grpc gotools gotests go-migrate
          protobuf cmake ninja pkg-config autoconf autoconf-archive automake libtool m4 bison
          podman podman-compose nodejs_22 stripe-cli inetutils

          (pkgs.writeShellScriptBin "docker" ''
            export PODMAN_IGNORE_CGROUPSV1_WARNING=1
            export XDG_CONFIG_HOME="$HOME/.config"
            exec ${pkgs.podman}/bin/podman "$@"
          '')

          (pkgs.writeShellScriptBin "docker-compose" ''
            export XDG_CONFIG_HOME="$HOME/.config"
            exec ${pkgs.podman-compose}/bin/podman-compose "$@"
          '')

          (python3.withPackages (ps: with ps; [ pip black autopep8 pycodestyle ]))
        ];

        shellHook = ''
          export PATH="/usr/bin:/usr/sbin:$PATH"

          # Go workspace
          export GOPATH="$HOME/go"
          export PATH="$GOPATH/bin:$PATH"

          # Python local bins (pip install --user)
          export PATH="$HOME/.local/bin:$PATH"
        '';
      };

    };
}