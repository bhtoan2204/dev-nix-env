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

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [

          # === Core utilities ===
          git
          gh
          curl
          wget
          gnumake
          tree
          htop
          tmux
          screen
          unzip
          zip
          entr
          jq
          yq-go

          # === Search & file tools ===
          ripgrep
          fd
          bat
          fzf

          # === Go toolchain ===
          go
          gopls
          golangci-lint
          grpcurl
          mockgen
          protoc-gen-go
          protoc-gen-go-grpc
          gotools        # goimports, guru, godoc, ...
          gotests
          go-migrate     # CLI: migrate

          # === Protobuf / gRPC ===
          protobuf       # protoc

          # === Build tools ===
          cmake
          ninja
          pkg-config
          autoconf
          autoconf-archive
          automake
          libtool
          m4
          bison

          # === Kubernetes / DevOps ===
          kubectl
          kubernetes-helm
          k9s
          terraform

          # === Container (Podman) ===
          podman
          podman-compose

          # === Runtimes / languages ===
          (python3.withPackages (ps: with ps; [
            pip
            black
            autopep8
            pycodestyle
          ]))
          nodejs_22

          # === Java ===
          jdk17_headless
          maven

          # === Data / media ===
          yt-dlp
          kcat
          mpv

          # === Other CLI ===
          stripe-cli
          inetutils
        ];

        shellHook = ''
          # Podman as drop-in Docker replacement
          alias docker=podman
          alias docker-compose=podman-compose
          export PODMAN_IGNORE_CGROUPSV1_WARNING=1

          # Go workspace
          export GOPATH="$HOME/go"
          export PATH="$GOPATH/bin:$PATH"

          # Python local bins (pip install --user)
          export PATH="$HOME/.local/bin:$PATH"

          # Note: google/wire and protoc-gen-validate not in nixpkgs.
          # Install once manually:
          #   go install github.com/google/wire/cmd/wire@latest
          #   go install github.com/envoyproxy/protoc-gen-validate@latest

          echo "Dev environment ready — Podman $(podman --version 2>/dev/null | awk '{print $3}'), Go $(go version | awk '{print $3}')"
        '';
      };

    };
}
