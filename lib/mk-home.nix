{ inputs }:

{
  username,
  system,
  platform,
  extraModules ? [ ],
  nixpkgsInput ? inputs.nixpkgs,
}:
let
  pkgs = import nixpkgsInput {
    inherit system;
    config.allowUnfree = true;
  };
  platformModule =
    if platform == "darwin" then ../modules/darwin/home.nix else ../modules/linux/home.nix;
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = { inherit username; };
  modules = [ platformModule ] ++ extraModules;
}
