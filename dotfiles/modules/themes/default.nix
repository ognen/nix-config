{
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  imports = [
    ./catppuccin.nix
  ];

  options.local.themes = {
    light = mkOption {
      type = types.enum [ "catppuccin-latte" ];
      description = "The light theme";
    };

    dark = mkOption {
      type = types.enum [ "catppuccin-mocha" ];
      description = "The dark theme";
    };
  };

}
