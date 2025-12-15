{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.nushell;
  setEnvironment = config.system.build.setEnvironment;
  inherit (lib) mkIf mkEnableOption;
in
{
  options.local.nushell = {
    enable = mkEnableOption "nushell";
  };

  config = mkIf (cfg.enable) {
    environment.systemPackages = [
      pkgs.nushell
    ];

    environment.shells = [ pkgs.nushell ];

    environment.etc = {
      "nushell/capture-env.nu".source = pkgs.writeText "capture-env.nu" (
        builtins.readFile ./capture-env.nu
      );
      "nushell/nix-env.nu".text = ''
        use /etc/nushell/capture-env.nu

        if $env not-has "__NIX_DARWIN_SET_ENVIRONMENT_DONE=1" {
          capture-env ${setEnvironment} | load-env
        }
      '';

    };
  };

}
