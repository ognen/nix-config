# Provides a unified pacakge with all language servers
{
  lib,
  clojure-lsp,
  nixd,
  efm-langserver,
  vscode-langservers-extracted,
  symlinkJoin,
  prettierd,
}:
symlinkJoin {
  name = "fp-langservers-bundle";
  paths = [
    clojure-lsp
    nixd
    efm-langserver
    vscode-langservers-extracted
    prettierd
  ];
}
