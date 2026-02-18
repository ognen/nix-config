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
in
{
  options.local.granted = {
    enable = mkEnableOption "granted";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.granted ];

    local.nushell.modules = [ grantedNushellModule ];

    programs.nushell.extraConfig = ''
      use granted-nushell.nu *
    '';
  };

}
