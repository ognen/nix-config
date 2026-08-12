{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) literalExpression mkOption types;
  cfg = config.local.user;
in
{
  options.local.user = {
    name = mkOption {
      type = types.str;
      description = "Login name of the user this machine is assigned to.";
    };

    homeDirectory = mkOption {
      type = types.str;
      default = "/Users/${cfg.name}";
      defaultText = literalExpression ''"/Users/''${config.local.user.name}"'';
      description = "Home directory of the machine's user.";
    };

    shell = mkOption {
      type = types.package;
      default = pkgs.nushell;
      defaultText = literalExpression "pkgs.nushell";
      description = "Login shell of the machine's user.";
    };
  };

  config = {
    users.users.${cfg.name} = {
      name = cfg.name;
      shell = cfg.shell;
      home = cfg.homeDirectory;
    };
  };
}
