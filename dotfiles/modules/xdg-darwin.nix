{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.xdg;
  inherit (lib) mkIf mkMerge;
in
{
  config = mkMerge [
    (
      let
        variables = {
          XDG_CACHE_HOME = cfg.cacheHome;
          XDG_CONFIG_HOME = cfg.configHome;
          XDG_DATA_HOME = cfg.dataHome;
          XDG_STATE_HOME = cfg.stateHome;
        };
      in
      {
        home.preferXdgDirectories = true;

        launchd = {
          enable = true;
          agents.xgd-config = {
            enable = true;
            config = {
              ProgramArguments = [
                "/bin/launchctl"
                "setenv"
              ]
              ++ (lib.concatLists (
                lib.mapAttrsToList (k: v: [
                  k
                  v
                ]) variables
              ));
              RunAtLoad = true;
            };
          };
        };
      }

    )
  ];
}
