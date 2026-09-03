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
            ./nix/modules/packages.nix
            hostModule
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit user; };
              home-manager.users.${user} = import ./nix/modules/home.nix;

              # $HOME currently holds real files copied there by chezmoi.
              # Without this the first activation refuses to clobber them.
              home-manager.backupFileExtension = "pre-nix";
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
