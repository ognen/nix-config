{
  pkgs,
  flakePath,
}:
let
  pkg = pkgs.nixd;
  formatter = pkgs.nixfmt;
  flake = "(builtins.getFlake ${flakePath})";
in
rec {
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

  emacsCustomizations = {
    lsp-nix-nixd-nixpkgs-expr = config.nixpkgs.expr;
    lsp-nix-nixd-nixos-options-expr = config.options.nixos.expr;
    lsp-nix-nixd-home-manager-options-expr = config.options.home-manager.expr;
  };
}
