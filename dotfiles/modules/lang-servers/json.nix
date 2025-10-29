{
  pkgs,
}:
let
  pkg = pkgs.vscode-langservers-extracted;
in
{
  package = pkg;

  command = "${pkg}/bin/vscode-json-language-server";
  args = [ "--stdio" ];
  config = {
    json = {
      format = {
        enable = false;
      };
      validate = {
        enable = true;
      };
    };
    provideFormatter = false;
  };
}
