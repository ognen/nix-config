{
  pkgs,
}:
let
  pkg = pkgs.typescript-language-server;
in
{
  package = pkg;
  command = "${pkg}/bin/typescript-language-server";
  args = [ "--stdio" ];
}
