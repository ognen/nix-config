{
  pkgs,
}:
let
  pkg = pkgs.emmet-ls;
in
{
  package = pkg;
  command = "${pkg}/bin/emmet-ls";
  args = [ "--stdio" ];
}
