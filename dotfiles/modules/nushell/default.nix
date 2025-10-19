{ config, specialArgs, pkgs, lib, ... }:
let
   catppuccin-theme = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "nushell";
    rev = "c0568b4a78f04be24f68c80284755d4635647aa1";
    hash = "sha256-vaGiZHoGkHr1QcshO8abIQL/zIuw3hFcBhDYcKhOpNw=";
  };
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.local.nushell;
  inherit (specialArgs) flakePkgs;
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
      
        configFile.source = ./config.nu;
        envFile.source = ./env.nu;

        extraConfig = ''
          # selected theme 
          source "${catppuccin-theme}/themes/catppuccin_mocha.nu";

          use "${flakePkgs.bash-env-nushell}/bash-env.nu"

          def --env "reload-hm-session-vars" [] {
            __ETC_PROFILE_NIX_SOURCED="" bash-env  /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh | load-env
            __HM_SESS_VARS_SOURCED="" bash-env ~/.nix-profile/etc/profile.d/hm-session-vars.sh | load-env
          }

          reload-hm-session-vars
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
