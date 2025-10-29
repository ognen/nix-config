{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.local.starship;
in
{
  options.local.starship = {
    enable = mkEnableOption "starship";
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;

      settings = builtins.fromJSON (builtins.readFile ./prompt.json) // {
        add_newline = true;
        cmd_duration.show_notifications = false;
      };
    };

    programs.carapace = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
