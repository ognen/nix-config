{
  pkgs,
  config,
  lib,
  specialArgs,
  ...
}:
let
  cfg = config.local.fonts;
  inherit (lib) mkIf mkEnableOption;
  inherit (specialArgs) flakePkgs;
in
  {
    options.local.fonts.enable = mkEnableOption "fonts";

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
         nerd-fonts.jetbrains-mono
         nerd-fonts.zed-mono
         ia-writer-quattro
         ia-writer-duospace
         emacs-all-the-icons-fonts
         flakePkgs.tx-02-font
      ];
    };
  }
