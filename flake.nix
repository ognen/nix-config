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

    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, mac-app-util}:
  let version = {
    system.configurationRevision = self.rev or self.dirtyRev or null;
    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    system.stateVersion = 6;
  }; in 
  {
    # This configuration is for machines where root access is
    # not available w/o intervention.
    #
    # A few system pacakges are installed and then the rest of them
    # are managed by home-manager 
    #     # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."default" = nix-darwin.lib.darwinSystem {
      modules = [
        home-manager.darwinModules.home-manager
        mac-app-util.darwinModules.default
        # enable mac-app-util for all user in home manager
        {
          home-manager.sharedModules = [
            mac-app-util.homeManagerModules.default
          ];
        }
        version
        
        # main host configuration
       ./hosts/default/configuration.nix
       ];
    };
  };
}
