{ pkgs, ... }:
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [ pkgs.vim
      pkgs.helix
      pkgs.fish
      # pkgs.nushell
    ];

  # We're using determinate nix
  nix.enable = false;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Shells
  programs.fish.enable = true;
  environment.shells = with pkgs; [ fish ];
  # environment.shells = with pkgs; [ nushell ];

  # Home Manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    backupFileExtension = "backup";
  }; 

  imports = [ ./oivanovs.nix ];
}
