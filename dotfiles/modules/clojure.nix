{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.local.clojure;
in
{
  options.local.clojure.enable = mkEnableOption "clojure";

  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
      (clojure.overrideAttrs { jdk = zulu25; })
      zulu25
    ];
  };
}
