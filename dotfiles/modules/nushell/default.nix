{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.local.nushell;
  inherit (lib.hm.nushell) toNushell;

  # Create a simple nushell module package for macos-appearance
  macosAppearanceModule = pkgs.writeTextDir "share/nushell/macos-appearance.nu" (
    builtins.readFile ./macos-appearance.nu
  );

in
{
  options.local.nushell = {
    enable = mkEnableOption "nushell";

    modules = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = ''
        List of packages providing nushell modules.
        Each package is expected to provide module files in share/nushell,
        typically as share/nushell/module.nu or share/nushell/module/mod.nu.
      '';
    };

    themes = mkOption {
      type = types.submodule {
        options = {
          light = mkOption {
            type = types.either types.path types.str;
            description = "Path or string for the light theme.";
          };
          dark = mkOption {
            type = types.either types.path types.str;
            description = "Path or string for the dark theme.";
          };
        };
      };
      description = "Light and dark theme configurations for nushell.";
    };

  };

  # TODO add a module that runs a hook on appearance mode change ()
  config = mkIf cfg.enable (mkMerge [
    {
      local.nushell.modules = [
        macosAppearanceModule
      ];

      programs = {
        nushell = {
          enable = true;

          settings = {
            buffer_editor = "hx";
            show_banner = false;

            history = {
              file_format = "sqlite";
              max_size = 1000000;
            };
          };
        };

      };

      # Load the nix-darwin system environment ahead of the session variables
      # loader that loadSessionVariables puts at the top of env.nu: nix-darwin's
      # set-environment replaces PATH and sets EDITOR, so running it afterwards
      # would undo home.sessionPath and home.sessionVariables. Under nix-darwin
      # the loader would load the system environment itself, so this only
      # matters for the standalone home configuration.
      home.file."${config.programs.nushell.configDir}/env.nu".text = lib.mkBefore ''
        if ('/etc/nushell/nix-env.nu' | path exists) {
          source /etc/nushell/nix-env.nu
        }
      '';

      home.packages = [
        pkgs.jc
      ]
      ++ cfg.modules;
    }
    ## Setup NU_LIB_DIRS to include standard data directories
    {
      programs.nushell.extraEnv = ''
        let xdg_data_paths = ($env.XDG_DATA_DIRS? | default "" | split row ":" | where $it != "" | each {|d| $"($d)/nushell"})
        let new_paths = [
          ${toNushell { } "${config.xdg.dataHome}/nushell"}
        ] | append $xdg_data_paths
        let existing = $env.NU_LIB_DIRS | default []
        $env.NU_LIB_DIRS = ($new_paths | where {|p| $p not-in $existing}) | append $existing
      '';
    }
  ]);
}
