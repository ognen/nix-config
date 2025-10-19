{
  config,
  lib,
  ...
}:
let
  cfg = config.local.git;
  inherit (lib) mkIf mkEnableOption;
in
  {
    options.local.git.enable = mkEnableOption "git";

    config = mkIf cfg.enable {
      programs.git = {
        enable = true;
        userEmail = "ognen.ivanovski@netcetera.com";
        userName = "Ognen Ivanovski";

        lfs.enable = true;

        extraConfig = {
          core = {
            eol = "native";
            autocrlf = "input";
            filemode = "false";
            whitespace = "trailing-space";
          };

          merge = {
            conflictStyle = "diff3";
          };
        };
      };

      programs.gh = {
        enable = true;

        settings = {
          version = 1;
          git_protocol = "https";
          prompt = "enabled";
          aliases = {
            co = "pr checkout";
          };
          color_labels = "enabled";
          spinner = "enabled";
        };

        hosts = {
          "github.com" = {
            git_protocol = "https";
            users = {
              ognen = {};
            };
            user = "ognen";
          };
        };
        
      };
    };
  }
