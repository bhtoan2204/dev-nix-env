{
  description = "Go and DevOps development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          go
          git
          gnumake
          neovim
          podman
          podman-compose
        ];

        shellHook = ''
          # Automatic aliases for Docker compatibility
          alias docker=podman
          alias docker-compose=podman-compose

          echo "🦭 Rootless Podman environment active!"
          echo "Aliases mapped: 'docker' -> 'podman' and 'docker-compose' -> 'podman-compose'"
        '';
      };

    };
}
