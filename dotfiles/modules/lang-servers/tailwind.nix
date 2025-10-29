{ pkgs }:
let
  pkg = pkgs.tailwindcss-language-server;
in
{
  package = pkg;

  command = "${pkg}/bin/tailwindcss-language-server";
  args = [ "--stdio" ];
}
