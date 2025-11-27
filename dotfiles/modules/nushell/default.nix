{
  config,
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
          config.home.sessionVariables
        ];

        extraEnv = ''
          if ('/etc/nushell/nix-env.nu' | path exists) {
            source /etc/nushell/nix-env.nu
          }
        '';

        extraConfig = ''
          use std/util 'path add'
          let sessionPath = ${toNushell { } config.home.sessionPath};

          if ($sessionPath | is-not-empty) {
            path add ...$sessionPath
          }

          # selected theme 
          source "${catppuccin-theme}/themes/catppuccin_mocha.nu";
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
      pkgs.jc
    ];
  };
}
