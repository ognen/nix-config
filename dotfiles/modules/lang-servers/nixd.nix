{
  pkgs,
  lib,
  flakePath,
}:
let
  libEmacs = import ../../../lib/emacs.nix { inherit lib; };
  pkg = pkgs.nixd;
  formatter = pkgs.nixfmt;
  flake = "(builtins.getFlake ${flakePath})";
  # The flake keys its configurations per machine (darwinConfigurations.<host>)
  # and per user (homeConfigurations."<user>@<host>"), so there is no fixed name
  # to point nixd at. Take the first entry instead: attrValues sorts by attribute
  # name, and a host's plain name sorts before its own "<host>-no-root" variant,
  # so this lands on a configuration that includes home-manager. With several
  # machines it picks whichever host sorts first — good enough for the option
  # completion this feeds. Evaluated lazily by nixd, not here.
  firstConfigurationOf = output: "(builtins.head (builtins.attrValues ${flake}.${output}))";
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
      nixos.expr = "${firstConfigurationOf "darwinConfigurations"}.options";
      home-manager.expr = "${firstConfigurationOf "homeConfigurations"}.options";
    };
  };

  emacsCustomizations = {
    lsp-nix-nixd-nixpkgs-expr = config.nixpkgs.expr;
    lsp-nix-nixd-nixos-options-expr = config.options.nixos.expr;
    lsp-nix-nixd-home-manager-options-expr = config.options.home-manager.expr;
  };

  emacsConfiguration = ''
    (with-eval-after-load 'eglot
      (add-to-list 'eglot-server-programs
        '((nix-mode nix-ts-mode)
          . ("${command}"
             :initializationOptions ${libEmacs.toEmacsPlist config}))))
  '';
}
