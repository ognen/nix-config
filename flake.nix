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

    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*";

    private-fonts = {
      url = "https://flakehub.com/f/ognen/fonts/0.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      # Every machine this flake manages, with the user it is assigned to and
      # that user's home-manager entry point. Adding a machine means adding an
      # entry here plus a hosts/<name>/ directory — nothing else.
      machines = {
        mb5619 = {
          system = "aarch64-darwin";
          user = "oivanovs";
          home = ./dotfiles/home.nix;
        };
      };

      # nixpkgs as this flake wants it, instantiated once per system and shared
      # by every output that needs it.
      pkgsBySystem = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;

          overlays = [
            inputs.fh.overlays.default
            inputs.llm-agents.overlays.shared-nixpkgs

            (final: prev: {
              tx-02-font = inputs.private-fonts.packages.${system}.TX-02;
            })
          ];
        }
      );

      pkgsFor = system: pkgsBySystem.${system};

      inherit
        (import ./lib {
          inherit
            inputs
            self
            lib
            pkgsFor
            ;
        })
        mkDarwin
        mkHome
        ;

      # The distinct systems the registry mentions.
      forAllSystems = lib.genAttrs (
        lib.unique (lib.mapAttrsToList (_: machine: machine.system) machines)
      );
    in
    {
      # Keyed by hostname: `darwin-rebuild --flake .` looks up
      # darwinConfigurations.$(scutil --get LocalHostName) and has no fallback.
      #
      # The "-no-root" variant is the same system without home-manager, for
      # machines where root access is not available w/o intervention; apply the
      # matching homeConfiguration alongside it.
      darwinConfigurations = lib.concatMapAttrs (name: machine: {
        ${name} = mkDarwin {
          inherit name machine;
          withHomeManager = true;
        };

        "${name}-no-root" = mkDarwin {
          inherit name machine;
          withHomeManager = false;
        };
      }) machines;

      # Standalone home-manager, keyed "<user>@<host>" so that
      # `home-manager switch --flake .` resolves without an argument.
      homeConfigurations = lib.mapAttrs' (
        name: machine:
        lib.nameValuePair "${machine.user}@${name}" (mkHome {
          inherit machine;
        })
      ) machines;

      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          claudeCode = pkgs.callPackage ./dotfiles/modules/claude/package.nix { };
          claudeCodeAcp = pkgs.callPackage ./dotfiles/modules/claude/acp.nix { };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = import inputs.nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShellNoCC {
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
              (writeShellApplication {
                name = "update-flake";
                runtimeInputs = [ nushell ];
                text = ''
                  echo "> Updating flake inputs..."
                  nix flake update

                  echo "> Updating Claude Code..."
                  (cd dotfiles/modules/claude && nu ./update.nu)

                  echo "> Updating Claude Code ACP..."
                  (cd dotfiles/modules/claude && nu ./update-acp.nu)

                  echo "> All updates complete"
                '';
              })
            ];
          };
        }
      );
    };
}
