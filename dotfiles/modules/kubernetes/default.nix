{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.local.kubernetes;
in
{
  options.local.kubernetes = {
    enable = (mkEnableOption "kubernetes") // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.kubectl ];
  };
}
