{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.local.claude;
in
{
  options.local.claude = {
    enable = mkEnableOption "claude";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.llm-agents.claude-code
      pkgs.llm-agents.claude-agent-acp
    ];
  };
}
