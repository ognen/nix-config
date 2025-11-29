{
  description = "Ognen's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";

    # Stable nix-darwin
    nix-darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Determinate module
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # fh = {
    #   url = "https://flakehub.com/f/DeterminateSystems/fh/*";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    private-fonts = {
      url = "https://flakehub.com/f/ognen/fonts/0.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      determinate,
      ...
    }:
    let
      system = "aarch64-darwin";
      username = "oivanovs";
      flakePkgs = {
        # fh = inputs.fh.packages.${system}.default;
        tx-02-font = inputs.private-fonts.packages.${system}.TX-02;
      };
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # This configuration is for machines where root access is
      # not available w/o intervention.
      darwinConfigurations."no-root" = nix-darwin.lib.darwinSystem {
        inherit system;

        modules = [
          inputs.determinate.darwinModules.default
          self.darwinModules.default
        ];
      };

      #
      # A few system pacakges are installed and then the rest of them
      # are managed by home-manager
      darwinConfigurations."default" = nix-darwin.lib.darwinSystem {
        inherit system;

        modules = [
          inputs.determinate.darwinModules.default
          self.darwinModules.default
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              users.${username} = ./dotfiles/home.nix;
            };
          }
        ];
      };

      # Standalone configuration for home manager, use it with
      # the no-root darwin configuration
      homeConfigurations."default" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./dotfiles/home.nix
        ];

        extraSpecialArgs = {
          inherit flakePkgs;
        };
      };

      darwinModules = {
        base =
          {
            config,
            pkgs,
            lib,
            ...
          }:
          {
            system.configurationRevision = self.rev or self.dirtyRev or null;
            # Used for backwards compatibility, please read the changelog before changing.
            # $ darwin-rebuild changelog
            system.stateVersion = 6;
          };

        nixConfig =
          {
            config,
            pkg,
            lib,
            ...
          }:
          {
            # Let Determinate Nix handle your Nix configuration
            nix.enable = false;

            # Custom Determinate Nix settings written to /etc/nix/nix.custom.conf
            determinate-nix.customSettings = {
              # Enables parallel evaluation (remove this setting or set the value to 1 to disable)
              eval-cores = 0;
              extra-experimental-features = [
                "build-time-fetch-tree" # Enables build-time flake inputs
                "parallel-eval" # Enables parallel evaluation
              ];
              # Other settings
            };
          };

        users.oivanovs =
          {
            config,
            pkg,
            lib,
            ...
          }:
          {
            users.users.oivanovs = {
              name = "oivanovs";
              shell = pkgs.nushell;
              home = "/Users/oivanovs";
            };
          };

        default =
          {
            config,
            pkg,
            lib,
            ...
          }:
          {
            imports = [
              self.darwinModules.base
              self.darwinModules.nixConfig
              ./hosts/default/configuration.nix
              self.darwinModules.users.${username}
            ];
          };
      };

      devShells.${system}.default =
        let
          pkgs = import inputs.nixpkgs { inherit system; };
        in
        pkgs.mkShellNoCC {
          packages = with pkgs; [
            # Shell script for applying the nix-darwin configuration.
            # Run this to apply the configuration in this flake to your macOS system.
            (writeShellApplication {
              name = "reload-nix-darwin-configuration";
              runtimeInputs = [
                # Make the darwin-rebuild package available in the script
                inputs.nix-darwin.packages.${system}.darwin-rebuild
              ];
              text = ''
                echo "> Applying nix-darwin configuration..."

                echo "> Running darwin-rebuild switch as root..."
                sudo darwin-rebuild switch --flake .
                echo "> darwin-rebuild switch was successful ✅"

                echo "> macOS config was successfully applied 🚀"
              '';
            })
          ];
        };
    };
}
