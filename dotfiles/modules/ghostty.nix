{
  config,
  lib,
  ...
}:
let
  cfg = config.local.ghostty;
  themes = config.local.themes;
  inherit (lib) mkEnableOption mkIf;

  # Ghostty ships the Catppuccin flavours under their display names.
  ghosttyThemeNames = {
    "catppuccin-latte" = "Catppuccin Latte";
    "catppuccin-mocha" = "Catppuccin Mocha";
  };
in
{
  options.local.ghostty = {
    enable = mkEnableOption "ghostty";
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;

      # The app itself comes from the Homebrew cask, so only the config file
      # is managed here. Set this to pkgs.ghostty to install it through nix.
      package = null;

      settings = {
        theme = "dark:${ghosttyThemeNames.${themes.dark}},light:${ghosttyThemeNames.${themes.light}}";

        font-family = "TX-02";
        font-size = 15;
        font-thicken = true;
        adjust-cell-height = "20%";

        macos-option-as-alt = "left";
        macos-titlebar-style = "transparent";

        keybind = [ "shift+enter=text:\\x1b\\r" ];
      };
    };
  };
}
