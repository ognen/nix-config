{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;
  cfg = config.local.clojure;
in
{
  options.local.clojure = {
    enable = mkEnableOption "clojure";

    zprint = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to manage `~/.zprintrc`.";
      };

      settings = mkOption {
        type = types.str;
        default = "{:search-config? true}";
        description = ''
          EDN written to `~/.zprintrc`. The default only turns on
          {option}`:search-config?`, which makes zprint walk up from the current
          directory looking for a project `.zprintrc`. Without it zprint stops
          at this file and project settings are ignored, so tools that shell out
          to zprint (clojure-lsp, clojure-mcp) format with the wrong style.
        '';
      };
    };
  };

  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
      (clojure.overrideAttrs { jdk = zulu25; })
      zulu25
    ];

    # Deliberately not under xdg.configFile: zprint looks for ~/.zprintrc (and
    # $ZPRINTRC), it does not honour XDG_CONFIG_HOME.
    home.file = mkIf cfg.zprint.enable {
      ".zprintrc".text = cfg.zprint.settings + "\n";
    };
  };
}
