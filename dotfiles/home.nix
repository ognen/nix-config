{
  config,
  pkgs,
  specialArgs,
  ...
}:
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
    ./modules/helix.nix
    ./modules/emacs/default.nix
    ./modules/lang-servers/default.nix
    ./modules/clojure.nix
    ./modules/themes/default.nix
  ];

  # allow unree
  nixpkgs.config.allowUnfree = true;

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
  local.helix.enable = true;
  local.emacs.enable = true;
  local.langServers.enable = true;
  local.langServers.flakePath = ../.;
  programs.ripgrep.enable = true;
  local.clojure.enable = true;

  # Themes
  local.themes = {
    light = "catppuccin-latte";
    dark = "catppuccin-mocha";
  };

  # extra use packages
  home.packages = with pkgs; [
    silver-searcher
    hunspell
    nix-tree
    bat
    # fh
    claude-code
    awscli2
    awsume
  ];

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  home.sessionVariables = {
    EDITOR = "hx";
  };

}
