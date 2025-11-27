{ pkgs, ... }:
{
  imports = [ ../../common/modules/nushell/default.nix ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.vim
    pkgs.helix
  ];

  # Shells
  local.nushell.enable = true;
  programs.fish.enable = true;
  programs.bash.enable = true;

  environment.shells = with pkgs; [
    fish
  ];
}
