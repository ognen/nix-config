{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption;
  tomlFormat = pkgs.formats.toml { };
  cfg = config.local.starship;

  presetFile =
    preset:
    pkgs.runCommand "starship-preset-${preset}"
      {
        buildInputs = [ config.programs.starship.package ];
      }
      ''
        starship preset ${preset} > $out
      '';

  starshipConfigType = lib.types.submodule {
    options = {
      preset = mkOption {
        type = lib.types.str;
        description = "The starship preset to use for this configuration";
      };

      extraSettings = mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Additional settings to merge with the preset";
      };
    };
  };

  generateStarshipConfig =
    config:
    let
      presetConfig = builtins.fromTOML (builtins.readFile (presetFile config.preset));
      mergedSettings = lib.mergeAttrs presetConfig config.extraSettings;
    in
    mergedSettings;
in
{
  options.local.starship = {
    enable = mkEnableOption "starship";

    settings = mkOption {
      type = starshipConfigType;
      description = "The default configuration";
    };

    alternateSettings = mkOption {
      type = lib.types.attrsOf starshipConfigType;
      default = { };
      description = "Alternate starship configurations with their own presets and settings";
    };
  };

  config = mkIf cfg.enable {
    local.starship.settings = {
      preset = "catppuccin-powerline";

      extraSettings = {
        line_break = {
          disabled = false;
        };
        character = {
          success_symbol = "[❯❯❯](bold fg:green)";
          error_symbol = "[❯❯❯](bold fg:red)";
        };
        cmd_duration.show_notifications = false;
      };
    };

    programs.starship = {
      enable = true;

      settings = (generateStarshipConfig cfg.settings);
    };

    xdg.configFile = lib.mapAttrs' (
      name: altConfig:
      lib.nameValuePair "starship/${name}.toml" {
        source = tomlFormat.generate "starship-${name}.toml" (generateStarshipConfig altConfig);
      }
    ) cfg.alternateSettings;

    programs.carapace = {
      enable = true;
      enableNushellIntegration = true;
    };

    programs.vivid = {
      enable = true;
      activeTheme = "catppuccin-mocha";
    };
  };
}
