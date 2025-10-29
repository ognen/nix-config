{ pkgs }:
let
  pkg = pkgs.vscode-langservers-extracted;
in
{
  package = pkg;
  command = "${pkg}/bin/vscode-css-language-server";
  args = [ "--stdio" ];
  config = {
    css = {
      enable = true;
    };
    less = {
      validate = {
        enable = true;
      };
    };
    provideFormatter = true;
    scss = {
      validate = {
        enable = true;
      };
    };
  };
}
