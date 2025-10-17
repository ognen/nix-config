{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "oivanovs";
  home.homeDirectory = "/Users/oivanovs";

  home.stateVersion = "25.05"; # Please read the comment before changing.

  xdg.enable = true;

  home.sessionPath = [
    "$HOME/.local/bin"
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  # TODO hunspell emacs fonts (maocs defaults config, e.g. kbd repeat etc, )
  imports = [
    ./modules/xdg-darwin.nix
    ./modules/fish/default.nix
    ./modules/nushell/default.nix
    ./modules/starship/default.nix
    ./modules/direnv.nix
  ];

  local.nushell.enable = true;
  local.starship.enable = true;
  local.direnv.enable = true;

  programs.ripgrep.enable = true;
  
  home.packages = with pkgs; [
    silver-searcher
    hunspell
  ];


  home.sessionVariables = {
    EDITOR = "hx";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
