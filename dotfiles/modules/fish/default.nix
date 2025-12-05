{
  pkgs,
  lib,
  config,
  ...
}:
let
  catppuccin-fish = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "fish";
    rev = "6a85af2ff722ad0f9fbc8424ea0a5c454661dfed";
    hash = "sha256-Oc0emnIUI4LV7QJLs4B2/FQtCFewRFVp7EDv8GawFsA=";
  };
  cfg = config.programs.fish;

  themes = lib.foldl (
    themeList: plugin:
    if lib.pathIsDirectory "${plugin.src}/themes" then
      themeList ++ lib.filesystem.listFilesRecursive "${plugin.src}/themes"
    else
      themeList
  ) [ ] cfg.plugins;
in
{
  programs.fish = {
    enable = true;

    plugins = [
      {
        name = "catpuccin-theme";
        src = catppuccin-fish;
      }
    ];

    shellInit = ''
      fish_config theme choose "Catppuccin Mocha"
    '';
  };

  # hack to enable themes from fish plugins unitil it is available upstram
  xdg.configFile = lib.mkMerge (
    map (
      theme:
      let
        basename = lib.last (builtins.split "/" (toString theme));
      in
      {
        "fish/themes/${basename}".source = theme;
      }
    ) themes
  );
  # TODO add the theme links manually as it's not currently supported
}
