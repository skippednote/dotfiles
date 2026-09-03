{
  description = "skippednote's macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # nix-darwin and home-manager release branches pair with nixpkgs
    # releases, so tracking nixpkgs-unstable means tracking master here.
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, nix-darwin, home-manager, ... }:
    let
      user = "skippednote";

      mkHost =
        { hostname, hostModule }:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit user hostname; };
          modules = [
            ./nix/modules/system.nix
            ./nix/modules/homebrew.nix
            ./nix/modules/defaults.nix
            hostModule
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit user; };
            }
          ];
        };
    in
    {
      darwinConfigurations = {
        personal = mkHost {
          hostname = "skippednote";
          hostModule = ./nix/hosts/personal.nix;
        };

        work = mkHost {
          hostname = "skippednote-work";
          hostModule = ./nix/hosts/work.nix;
        };
      };
    };
}
