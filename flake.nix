{
  description = "Ognen's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    }
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, mac-app-util}:
  let
    version = {
      system.configurationRevision = self.rev or self.dirtyRev or null;
      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;
    };
    system = "aarch65-darwin";
    pkgs = nixpkgs.legacyPackages.${system};
  in 
  {
    # This configuration is for machines where root access is
    # not available w/o intervention.
    darwinConfigurations."no-root" = nix-darwin.lib.darwinSystem {
      modules = [
        version
        mac-app-util.darwinModules.default
        ./hosts/default/configuration.nix
        ./hosts/default/oivanovs.nix
      ]
    };

    #
    # A few system pacakges are installed and then the rest of them
    # are managed by home-manager 
    #     # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."default" = nix-darwin.lib.darwinSystem {
      modules = [
        version
        home-manager.darwinModules.home-manager
        mac-app-util.darwinModules.default
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            sharedModules = [
              mac-app-util.homeManagerModules.default
            ];
          }
        }
        
        # main host configuration
       ./hosts/default/configuration.nix
       ./hosts/default/oivanovs.nix
       ];
    };

    # Standalone configuration for home manager, use it with
    # the no-root darwin configuration
    homeConfigurations."default" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [
        mac-app-util.homeManagerModules.default
        ./dotfiles/home.nix
      ];

      # Optionally use extraSpecialArgs
      # to pass through arguments to home.nix
    };
  };
}
