{
  config,
  lib,
  ...
}:
let
  cfg = config.local.user;
  inherit (lib)
    literalExpression
    mkDefault
    mkOption
    types
    ;
in
{
  options.local.user = {
    name = mkOption {
      type = types.str;
      description = ''
        Login name of the user this home-manager configuration is built for.
      '';
    };

    homeDirectory = mkOption {
      type = types.str;
      default = "/Users/${cfg.name}";
      defaultText = literalExpression ''"/Users/''${config.local.user.name}"'';
      description = ''
        Home directory of the user this home-manager configuration is built for.
      '';
    };
  };

  config = {
    # mkDefault so that home-manager's nix-darwin integration — which defines
    # both from users.users.<name> — wins when this module is evaluated as part
    # of a darwin system, and these win when it is evaluated standalone.
    home.username = mkDefault cfg.name;
    home.homeDirectory = mkDefault cfg.homeDirectory;
  };
}
