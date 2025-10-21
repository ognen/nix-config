{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.local.helix;
in
{
  options.local.helix.enable = mkEnableOption "helix";

  config = mkIf cfg.enable {
    programs.helix = {
      enable = true;

      settings = {
        theme = "catppuccin_mocha";

        editor = {
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };

          auto-save.focus-lost = true;
          soft-wrap.enable = true;
          inline-diagnostics.cursor-line = "warning";
          lsp.auto-signature-help = false;
          file-picker.hidden = false;
        };

        keys = {
          normal = {
            "Cmd-s" = ":write";
            "A-=" = ":format";
          };

          insert = {
            "Cmd-s" = ":write";
            "Cmd-p" = "signature_help";
          };
        };
      };
    };

    home.sessionVariables.EDITOR = "hx";
    programs.nushell.settings.buffer_editor = "hx";
  };

}
