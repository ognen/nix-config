{
  config,
  specialArgs,
  pkgs,
  lib,
  ...
}:
let
  catppuccin-theme = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "nushell";
    rev = "c0568b4a78f04be24f68c80284755d4635647aa1";
    hash = "sha256-vaGiZHoGkHr1QcshO8abIQL/zIuw3hFcBhDYcKhOpNw=";
  };
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.local.nushell;
  inherit (specialArgs) flakePkgs systemEnvironment;
  actualSystemPath =
    builtins.replaceStrings [ "$HOME" ] [ config.home.homeDirectory ]
      systemEnvironment.systemPath;
  path = config.home.sessionPath ++ (lib.strings.splitString ":" actualSystemPath);
  inherit (lib.hm.nushell) toNushell;
in
{
  options.local.nushell = {
    enable = mkEnableOption "nushell";
  };

  # TODO add help menu, and if posisble llm command assist menu
  config = mkIf cfg.enable {
    programs = {
      nushell = {
        enable = true;

        environmentVariables = mkMerge [
          (lib.mkDefault systemEnvironment.variables)
          config.home.sessionVariables
        ];

        extraConfig = ''
          # selected theme 
          source "${catppuccin-theme}/themes/catppuccin_mocha.nu";

          if $env not-has "__LOCAL_HM_SESS_VARS_SOURCED" {
            load-env {
              PATH: ${toNushell { } path}
              __LOCAL_HM_SESS_VARS_SOURCED: 1
            }
          }
        '';

        settings = {
          buffer_editor = "hx";
          show_banner = false;

          history = {
            file_format = "sqlite";
            max_size = 1000000;
          };
        };
      };
    };

    home.packages = [
      flakePkgs.bash-env-nushell
      pkgs.jc
    ];
  };
}
