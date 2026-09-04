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

    # A second nixpkgs, deliberately not following the first, so the agent
    # CLIs can be moved with `nix flake update nixpkgs-agents` without
    # dragging the other 58 packages along. They ship far more often than
    # everything else here.
    nixpkgs-agents.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs-agents, nix-darwin, home-manager, ... }:
    let
      user = "skippednote";
      system = "aarch64-darwin";

      # claude-code is unfree, so this needs its own config rather than
      # legacyPackages.
      agentPkgs = import nixpkgs-agents {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      darwinConfigurations.personal = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit user agentPkgs; };
        modules = [
          ./nix/modules/system.nix
          ./nix/modules/homebrew.nix
          ./nix/modules/defaults.nix
          ./nix/modules/packages.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit user; };
            home-manager.users.${user} = import ./nix/modules/home.nix;

            # $HOME held real files copied there by chezmoi, which the first
            # activation would otherwise refuse to clobber.
            home-manager.backupFileExtension = "pre-nix";
          }
        ];
      };
    };
}
