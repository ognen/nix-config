{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.local.claude;
  claudeCode = pkgs.callPackage ./package.nix { };
  claudeCodeAcp = pkgs.callPackage ./acp.nix { };
in
{
  options.local.claude = {
    enable = lib.mkEnableOption "claude";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      claudeCode
      claudeCodeAcp
    ];
  };
}
