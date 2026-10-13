{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.local.granted;

  grantedNushellModule = pkgs.writeTextDir "share/nushell/granted-nushell.nu" (
    builtins.readFile ./granted-nushell.nu
  );

  awsEnvNushellModule = pkgs.writeTextDir "share/nushell/aws-env.nu" (builtins.readFile ./aws-env.nu);
in
{
  options.local.granted = {
    enable = mkEnableOption "granted";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.granted ];

    local.nushell.modules = [
      grantedNushellModule
      awsEnvNushellModule
    ];

    programs.nushell.extraConfig = ''
      use granted-nushell.nu *
      use aws-env.nu *
    '';
  };

}
