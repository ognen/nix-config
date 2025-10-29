{
  pkgs,
}:
let
  pkg = pkgs.vscode-langservers-extracted;
in
{
  package = pkg;
  command = "${pkg}/bin/vscode-html-language-server";
  args = [ "--stdio" ];
}
