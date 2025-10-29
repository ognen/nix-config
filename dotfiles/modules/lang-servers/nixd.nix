{
  pkgs,
  flakePath,
}:
let
  pkg = pkgs.nixd;
  formatter = pkgs.nixfmt;
  flake = "(builtins.getFlake ${flakePath})";
in
{
  packages = [
    pkg
    formatter
  ];
  command = "${pkg}/bin/nixd";

  config = {
    nixpkgs.expr = "${flake}.inputs.nixpkgs { }";
    formatting.command = [ "${formatter}/bin/nixfmt" ];

    options = {
      nixos.expr = "${flake}.inputs.darwinConfigurations.default.options";
      home-manager.expr = "${flake}.homeConfigurations.default.options";
    };
  };
}
