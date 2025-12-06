{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.local.themes;
  inherit (lib) mkIf mkMerge;
  toNushell = lib.hm.nushell.toNushell { };

  catppuccinNushell = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "nushell";
    rev = "c0568b4a78f04be24f68c80284755d4635647aa1";
    hash = "sha256-vaGiZHoGkHr1QcshO8abIQL/zIuw3hFcBhDYcKhOpNw=";
  };
  lightTheme = cfg.light;
  darkTheme = cfg.dark;
  isCatppuccin = lib.hasPrefix "catppuccin-";
  toSnakeCase = lib.replaceString "-" "_";
  vividOn = config.programs.vivid.enable;
  starshipOn = config.programs.starship.enable;

  themedStarshipSettings = palette: {
    preset = "catppuccin-powerline";

    extraSettings = config.local.starship.settings.extraSettings or { } // {
      palette = palette;
    };
  };
in
{
  config = mkMerge [
    # starship light and dark configs
    (mkIf (config.local.starship.enable && (isCatppuccin lightTheme)) {
      local.starship.alternateSettings = {
        ${lightTheme} = themedStarshipSettings (toSnakeCase lightTheme);
      };
    })
    (mkIf (config.local.starship.enable && (isCatppuccin darkTheme)) {
      local.starship.alternateSettings = {
        ${darkTheme} = themedStarshipSettings (toSnakeCase darkTheme);
      };
    })

    # Helix; uncomment this once the next version is released
    # (mkIf (config.local.helix.enable && (isCatppuccin lightTheme)) {
    #   programs.helix.settings.theme.light = (toSnakeCase lightTheme);
    # })
    # (mkIf (config.local.helix.enable && (isCatppuccin darkTheme)) {
    #   programs.helix.settings.theme.dark = (toSnakeCase darkTheme);
    # })

    # Nushell
    (mkIf (config.local.nushell.enable) {
      programs.nushell.extraConfig = lib.concatStringsSep "\n\n" (
        (lib.optional ((isCatppuccin lightTheme) || (isCatppuccin darkTheme)) ''
          use macos-appearance.nu [ appearance-hook ]
        '')
        ++ (lib.optional (isCatppuccin lightTheme) ''

          appearance-hook {|mode|
            if $mode == "light" {
              source "${catppuccinNushell}/themes/${toSnakeCase lightTheme}.nu"

              ${lib.optionalString vividOn "$env.LS_COLORS = (vivid generate ${lightTheme})"}
              ${lib.optionalString starshipOn ''$env.STARSHIP_CONFIG = "${config.xdg.configHome}/starship/${lightTheme}.toml"''}
            }
          }
        '')
        ++ (lib.optional (isCatppuccin darkTheme) ''
          appearance-hook {|mode|
            if $mode == "dark" {
              source "${catppuccinNushell}/themes/${toSnakeCase darkTheme}.nu"

              ${lib.optionalString vividOn "$env.LS_COLORS = (vivid generate ${darkTheme})"}
              ${lib.optionalString starshipOn ''$env.STARSHIP_CONFIG = "${config.xdg.configHome}/starship/${darkTheme}.toml"''}
            }
          }
        '')
      );
    })
  ];
}
