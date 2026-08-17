{
  description = "Toan's reproducible terminal-first development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Nixpkgs unstable dropped Intel macOS after 26.05.
    nixpkgs-darwin-intel.url = "git+https://github.com/NixOS/nixpkgs?ref=nixpkgs-26.05-darwin&shallow=1";

    home-manager = {
      url = "git+https://github.com/nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "git+https://github.com/nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      nixpkgs-darwin-intel,
      home-manager,
      nix-darwin,
      ...
    }:
    let
      lib = nixpkgs.lib;
      hosts = import ./hosts;
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = lib.genAttrs supportedSystems;
      nixpkgsFor = system: if system == "x86_64-darwin" then nixpkgs-darwin-intel else nixpkgs;
      mkEnvironment = system: import ./lib/mk-packages.nix { nixpkgs = nixpkgsFor system; } system;
      mkHome = import ./lib/mk-home.nix { inherit inputs; };
      darwinPkgsFor =
        system:
        import (nixpkgsFor system) {
          inherit system;
          config.allowUnfree = true;
          overlays = [ nix-darwin.overlays.default ];
        };
    in
    {
      packages = forAllSystems (
        system:
        let
          environment = mkEnvironment system;
          mkBundle =
            name: paths:
            environment.pkgs.buildEnv {
              name = "dev-${name}";
              inherit paths;
            };
        in
        (lib.mapAttrs (name: packages: mkBundle name packages) environment.groups)
        // {
          default = mkBundle "global-env" environment.allPackages;
        }
      );

      devShells = forAllSystems (
        system:
        let
          environment = mkEnvironment system;
        in
        {
          default = environment.pkgs.mkShell {
            packages = environment.allPackages;
            shellHook = ''
              export GOPATH="''${GOPATH:-$HOME/go}"
              export PATH="$GOPATH/bin:$HOME/.local/bin:$PATH"
            '';
          };
        }
      );

      formatter = forAllSystems (system: (mkEnvironment system).pkgs.nixfmt);

      apps = forAllSystems (
        system:
        lib.optionalAttrs (builtins.hasAttr system home-manager.packages) {
          home-manager = {
            type = "app";
            program = "${home-manager.packages.${system}.default}/bin/home-manager";
            meta.description = "Apply a standalone Home Manager configuration";
          };
        }
        // lib.optionalAttrs (lib.hasSuffix "darwin" system) {
          darwin-rebuild = {
            type = "app";
            program = "${(darwinPkgsFor system).darwin-rebuild}/bin/darwin-rebuild";
            meta.description = "Apply a nix-darwin configuration";
          };
        }
      );

      homeConfigurations = {
        ubuntu = mkHome {
          inherit (hosts) username;
          inherit (hosts.ubuntu) system;
          platform = "linux";
          extraModules = [ ./hosts/ubuntu ];
        };
        macos = mkHome {
          inherit (hosts) username;
          inherit (hosts.macos) system;
          platform = "darwin";
        };
        macos-intel = mkHome {
          inherit (hosts) username;
          inherit (hosts.macos-intel) system;
          platform = "darwin";
          nixpkgsInput = nixpkgs-darwin-intel;
        };
      };

      darwinConfigurations = {
        macos = nix-darwin.lib.darwinSystem {
          inherit (hosts.macos) system;
          pkgs = darwinPkgsFor hosts.macos.system;
          specialArgs = { inherit (hosts) username; };
          modules = [
            ./hosts/macos
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit (hosts) username; };
              home-manager.users.${hosts.username}.imports = [ ./modules/darwin/home.nix ];
            }
          ];
        };

        macos-intel = nix-darwin.lib.darwinSystem {
          inherit (hosts.macos-intel) system;
          pkgs = darwinPkgsFor hosts.macos-intel.system;
          specialArgs = { inherit (hosts) username; };
          modules = [
            ./hosts/macos
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit (hosts) username; };
              home-manager.users.${hosts.username}.imports = [ ./modules/darwin/home.nix ];
            }
          ];
        };
      };

      nixosConfigurations.nixos = lib.nixosSystem {
        inherit (hosts.nixos) system;
        specialArgs = { inherit (hosts) username; };
        modules = [
          ./hosts/nixos
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit (hosts) username; };
            home-manager.users.${hosts.username}.imports = [ ./modules/nixos/home.nix ];
          }
        ];
      };
    };
}
