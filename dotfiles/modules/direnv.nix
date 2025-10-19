{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.local.direnv;
in
  {
    options.local.direnv.enable = mkEnableOption "direnv";

    config = mkIf cfg.enable {
      programs = {
        direnv.enable = true;
        direnv.enableNushellIntegration = true;
        direnv.nix-direnv.enable = true;
      };
    };
  }
