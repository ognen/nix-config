# Helpers that turn an entry of flake.nix's `machines` registry into a system
# configuration.
#
# mkDarwin and mkHome build the *same* home-manager module, so the module
# embedded in a darwin configuration and the standalone one cannot drift apart.
{
  inputs,
  self,
  lib,
  pkgsFor,
}:
let
  inherit (inputs) home-manager nix-darwin;

  # The home-manager configuration of the machine's assigned user: the user
  # module (which turns local.user.name into home.username/homeDirectory) plus
  # the machine's home-manager entry point.
  homeModuleFor = machine: {
    imports = [
      ../dotfiles/modules/user.nix
      machine.home
    ];

    local.user.name = machine.user;
  };
in
{
  # A nix-darwin system for `machine`, named `name`. With withHomeManager the
  # user's home-manager configuration is built as part of the system; without
  # it, apply the standalone homeConfiguration from mkHome instead.
  mkDarwin =
    {
      name,
      machine,
      withHomeManager,
    }:
    nix-darwin.lib.darwinSystem {
      inherit (machine) system;
      pkgs = pkgsFor machine.system;

      # modules/darwin/base.nix reads self.rev for system.configurationRevision.
      specialArgs = { inherit inputs self; };

      modules = [
        inputs.determinate.darwinModules.default

        # One wrapper module rather than five flat entries: the shape of the
        # module graph decides the merge order of list options such as
        # environment.systemPackages, and this keeps that order (and therefore
        # system.path) identical to what a single imported module produces.
        {
          imports = [
            ../modules/darwin/base.nix
            ../modules/darwin/nix-config.nix
            ../modules/darwin/common.nix
            ../modules/darwin/user.nix
            ../hosts/${name}
          ];
        }

        { local.user.name = machine.user; }
      ]
      ++ lib.optionals withHomeManager [
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            users.${machine.user} = homeModuleFor machine;
          };
        }
      ];
    };

  # A standalone home-manager configuration for the machine's assigned user.
  mkHome =
    { machine }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor machine.system;

      modules = [ (homeModuleFor machine) ];
    };
}
