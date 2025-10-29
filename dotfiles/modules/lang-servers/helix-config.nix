{
  package,
  lib,
  langServers,
}:
let
  getAttrs' = (
    keys: attrset: lib.getAttrs (builtins.filter (k: builtins.hasAttr k attrset) keys) attrset
  );
in
{
  programs.helix.languages.language-server = builtins.mapAttrs (
    _: ls: getAttrs' [ "command" "args" "config" ] ls
  ) langServers;
  programs.helix.languages.language = [
    {
      name = "clojure";
      auto-format = true;
      language-servers = [ "clojure-lsp" ];
      formatter.command = "${package}/bin/zprint";
    }
    {
      name = "nix";
      auto-format = true;
      language-servers = [
        {
          name = "nixd";
          except-features = [ "format" ];
        }
      ];
      formatter.command = "${package}/bin/nixfmt";
    }
    {
      name = "typescript";
      auto-format = true;
      formatter = {
        # leave it to direnv for the correct version
        command = "prettier";
        args = [
          "--parser"
          "typescript"
        ];
      };
      language-servers = [
        "typescript"
        {
          except-features = [ "format" ];
          name = "eslint";
        }
        {
          name = "efm";
          only-features = [ "format" ];
        }
        "emmet-ls"
      ];
    }
    {
      auto-format = true;
      name = "tsx";
      formatter = {
        command = "prettier";
        args = [
          "--parser"
          "typescript"
        ];
      };
      language-servers = [
        "typescript"
        "tailwind"
        {
          except-features = [ "format" ];
          name = "eslint";
        }
        {
          name = "efm";
          only-features = [ "format" ];
        }
        "emmet-ls"
      ];
    }
    {
      name = "javascript";
      auto-format = true;
      formatter = {
        command = "prettier";
        args = [
          "--parser"
          "typescript"
        ];
      };
      language-servers = [
        "typescript"
        {
          except-features = [ "format" ];
          name = "eslint";
        }
        {
          name = "efm";
          only-features = [ "format" ];
        }
        "emmet-ls"
      ];
    }
    {
      name = "jsx";
      auto-format = true;
      formatter = {
        command = "prettier";
        args = [
          "--parser"
          "typescript"
        ];
      };
      language-servers = [
        "typescript"
        "tailwind"
        {
          name = "eslint";
          except-features = [ "format" ];
        }
        {
          name = "efm";
          only-features = [ "format" ];
        }
        "emmet-ls"
      ];
    }
    {
      name = "json";
      auto-format = true;
      formatter = {
        command = "prettier";
        args = [
          "--parser"
          "json"
        ];
      };
    }
    {
      name = "html";
      auto-format = true;
      formatter = {
        command = "prettier";
        args = [
          "--parser"
          "html"
        ];
      };
      language-servers = [
        "vscode-html-language-server"
        "emmet-ls"
      ];
    }
    {
      name = "css";
      auto-format = true;
      formatter = {
        command = "prettier";
        args = [
          "--parser"
          "css"
        ];
      };
      language-servers = [
        "css"
        "emmet-ls"
      ];
    }
  ];
}
