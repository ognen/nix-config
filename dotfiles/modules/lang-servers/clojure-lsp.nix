{
  pkgs,
}:
let
  pkg = pkgs.clojure-lsp;
in
{
  packages = [
    pkg
    pkgs.zprint
  ];
  command = "${pkg}/bin/clojure-lsp";
}
