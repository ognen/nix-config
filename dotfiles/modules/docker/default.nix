{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.local.docker;
in
{
  options.local.docker = {
    enable = mkEnableOption "docker";
  };

  config = mkIf cfg.enable {
    programs.docker-cli.enable = true;

    services.colima.enable = true;
  };

}
