{
  config,
   pkgs,
  lib,
  ...
}:
let
  cfg = config.local.ghostty;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.local.ghostty = {
    enable = mkEnableOption "ghostty";
  };

  config = mkiIf (cfg.enable) {
    programs.ghostty.enable = true;

  };
}
