{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.local.pi;
in
{
  options.local.pi = {
    enable = mkEnableOption "pi coding agent";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.llm-agents.pi ];
  };
}
