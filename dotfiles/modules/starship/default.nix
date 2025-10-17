{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.local.starship;
in
  {
    options.local.starship = {
      enable = mkEnableOption "starship";
    };
      

    config = mkIf cfg.enable {
      programs.starship =  {
        enable = true;

        settings =
          builtins.fromJSON (builtins.readFile ./prompt.json)
          //
          {
            add_newline = true;
          };
      };

      programs.carapace = {
        enable = true;
        enableNushellIntegration = true;
      };
    };
  }
  
