{ config, pkgs, specialArgs, ... }:
let
  inherit (specialArgs) flakePkgs;
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "oivanovs";
  home.homeDirectory = "/Users/oivanovs";
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # TODO hunspell emacs fonts (maocs defaults config, e.g. kbd repeat etc, )
  imports = [
    ./modules/xdg-darwin.nix
    ./modules/fish/default.nix
    ./modules/nushell/default.nix
    ./modules/starship/default.nix
    ./modules/direnv.nix
    ./modules/git.nix
    ./modules/fonts/default.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  # use XDG
  xdg.enable = true;

  # Other programs and features
  local.nushell.enable = true;
  local.starship.enable = true;
  local.direnv.enable = true;
  local.git.enable = true;
  local.fonts.enable = true;
  programs.ripgrep.enable = true;
  
  # extra use packages
  home.packages = with pkgs; [
    silver-searcher
    hunspell
    nix-tree
    bat
    flakePkgs.fh
  ];

  home.sessionPath = [
    "$HOME/.local/bin"
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  home.sessionVariables = {
    EDITOR = "hx";
  };

}
