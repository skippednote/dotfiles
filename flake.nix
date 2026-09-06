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
    {
      self,
      nixpkgs,
      nixpkgs-agents,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      user = "skippednote";
      system = "aarch64-darwin";

      # claude-code is unfree, so this needs its own config rather than
      # legacyPackages.
      agentPkgs = import nixpkgs-agents {
        inherit system;
        config.allowUnfree = true;
      };

      # `make switch` picks the host from `scutil --get LocalHostName`, which
      # already returns skippednote / skippedbook on the respective machines,
      # so no flag can be got wrong.
      mkHost =
        { hostname, profiles }:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit user hostname agentPkgs; };
          modules = [
            ./nix/modules/system.nix
            ./nix/modules/gc.nix
            ./nix/modules/homebrew.nix
            ./nix/modules/defaults.nix
            ./nix/hosts/${hostname}.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit user hostname; };
              home-manager.users.${user} = import ./nix/modules/home.nix;

              # $HOME held real files copied there by chezmoi, which the first
              # activation would otherwise refuse to clobber.
              home-manager.backupFileExtension = "pre-nix";
            }
          ]
          ++ profiles;
        };
    in
    {
      # `nix fmt` / `make fmt`
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;

      # `nix flake check` does not force home.file.<name>.source, and neither
      # does building system.build.toplevel - verified by renaming a tracked
      # file in a scratch copy and watching every check still pass. So the
      # existence assert in nix/modules/home.nix only fires if something
      # forces those values. This does, for every host.
      checks.${system}.home-file-targets =
        let
          sourcesOf =
            host:
            builtins.attrValues (
              builtins.mapAttrs (
                _: f: f.source
              ) self.darwinConfigurations.${host}.config.home-manager.users.${user}.home.file
            );
          all = builtins.concatMap sourcesOf (builtins.attrNames self.darwinConfigurations);
        in
        nixpkgs.legacyPackages.${system}.runCommandLocal "home-file-targets" {
          inherit all;
        } "echo ok > $out";

      darwinConfigurations = {
        skippednote = mkHost {
          hostname = "skippednote";
          profiles = [
            ./nix/profiles/common.nix
            ./nix/profiles/dev.nix
          ];
        };

        skippedbook = mkHost {
          hostname = "skippedbook";
          profiles = [
            ./nix/profiles/common.nix
            ./nix/profiles/ops.nix
          ];
        };
      };
    };
}
