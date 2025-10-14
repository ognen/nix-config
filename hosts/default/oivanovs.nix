{ pkgs, lib, config, ... }:
let
  inherit (lib) mkMerge mkIf;
  cfg = config;
in 
{
  config = mkMerge [
    {
      users.users.oivanovs = {
        name = "oivanovs";
        shell = pkgs.fish;
        home = "/Users/oivanovs";
      };
    }
    mkIf (cfg ? home-manager.useGlobalPkgs) {
      home-manager.users.oivanovs = ../../dotfiles/home.nix;
    }
  ];
}
