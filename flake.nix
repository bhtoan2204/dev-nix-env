{
  description = "Portable Go, Rust, and DevOps development environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      mkEnvironment = system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          systemPackages = import ./nix/packages/system.nix { inherit pkgs; };
          goPackages = import ./nix/packages/go.nix { inherit pkgs; };
          rustPackages = import ./nix/packages/rust.nix { inherit pkgs; };
          devopsPackages = import ./nix/packages/devops.nix { inherit pkgs; };

          allPackages = systemPackages ++ goPackages ++ rustPackages ++ devopsPackages;
        in
        {
          inherit pkgs allPackages;
        };
    in
    {
      packages = forAllSystems (system:
        let
          environment = mkEnvironment system;
        in
        {
          default = environment.pkgs.buildEnv {
            name = "dev-global-env";
            paths = environment.allPackages;
          };
        });

      devShells = forAllSystems (system:
        let
          environment = mkEnvironment system;
        in
        {
          default = environment.pkgs.mkShell {
            packages = environment.allPackages;

            shellHook = ''
              export PATH="/usr/bin:/usr/sbin:$PATH"

              # Go workspace
              export GOPATH="$HOME/go"
              export PATH="$GOPATH/bin:$PATH"

              # Python local bins (pip install --user)
              export PATH="$HOME/.local/bin:$PATH"
            '';
          };
        });
    };
}
