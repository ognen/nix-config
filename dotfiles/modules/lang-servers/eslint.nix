{ pkgs }:
let
  pkg = pkgs.vscode-langservers-extracted;
in
{
  package = pkg;
  command = "${pkg}/bin/vscode-eslint-language-server";
  args = [ "--stdio" ];
  config = {
    codeAction = {
      disableRuleComment = {
        enable = true;
        location = "separateLine";
      };
      showDocumentation = {
        enable = true;
      };
    };
    format = false;
    onIgnoredFiles = "off";
    problems = {
      shortenToSingleLine = false;
    };
    quiet = false;
    run = "onType";
    validate = "on";
  };
}
