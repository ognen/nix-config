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
  modulePath = "nushell/modules";

  # Takes either a package or a path and returns a path under modulePath
  moduleTarget =
    m:
    let
      name = if lib.isDerivation m then m.pname or m.name else builtins.baseNameOf m;
    in
    "${modulePath}/${name}";

in
{
  options.local.nushell = {
    enable = mkEnableOption "nushell";

    modules = mkOption {
      type = types.listOf (types.either types.package types.path);
      default = [ ];
      description = "List of modules, each being either a package or a path to a file.";
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
        ./macos-appearance.nu
      ];

      programs = {
        nushell = {
          enable = true;

          environmentVariables = mkMerge [
            config.home.sessionVariables
          ];

          extraEnv = ''
            if ('/etc/nushell/nix-env.nu' | path exists) {
              source /etc/nushell/nix-env.nu
            }
          '';

          extraConfig = ''
            use std/util 'path add'
            let sessionPath = ${toNushell { } config.home.sessionPath};

            if ($sessionPath | is-not-empty) {
              path add ...$sessionPath
            }
          '';

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

      home.packages = [
        pkgs.jc
      ];
    }
    ## Setup modules
    (mkIf (cfg.modules != [ ]) {
      xdg.dataFile = builtins.listToAttrs (
        map (m: {
          name = moduleTarget m;
          value = {
            source = m;
          };
        }) cfg.modules
      );

      programs.nushell.extraEnv = ''
        $env.NU_LIB_DIRS = $env.NU_LIB_DIRS | default [] | append ${
          toNushell { } "${config.xdg.dataHome}/${modulePath}"
        }
      '';
    })
  ]);
}
