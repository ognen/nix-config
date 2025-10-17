{ pkgs, ... }:
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [ pkgs.vim
      pkgs.helix
      pkgs.nushell
      # pkgs.fish
      # pkgs.nushell
    ];

  # Shells
  programs.fish.enable = true;
  programs.bash.enable = true;
  # programs.nushell.enable = true;
  environment.shells = with pkgs; [ fish nushell ];
}
