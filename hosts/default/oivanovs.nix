{ pkgs, ... }:
{
  users.users.oivanovs = {
    name = "oivanovs";
    shell = pkgs.fish;
    home = "/Users/oivanovs";
  };

  home-manager.users.oivanovs = {pkgs, ... }: {
    imports = [
       ../../modules/home-manager/fish.nix
     ];
    
    home.username = "oivanovs";
    # home.homeDirectory = "/Users/oivanovs";

    home.stateVersion = "25.05";  

    xdg.enable = true;
    
  };
}
