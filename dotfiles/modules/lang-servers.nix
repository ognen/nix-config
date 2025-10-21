{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.local.langServers;
  inherit (lib) mkEnableOption mkIf;
  langServers = {
    clojure = {
      command = "${pkgs.clojure-lsp}/bin/clojure-lsp";
    };
    nixd = {
      command = "${pkgs.nixd}/bin/nixd";
      config = {
        options = {
          home-manager.expr = "(builtins.getFlake (builtins.toString ./.)).homeConfigurations.default.options";
        };
      };
    };
    efm = {
      command = "${pkgs.efm-langserver}/bin/efm-langserver";
    };
    eslint = {
      command = "${pkgs.vscode-langservers-extracted}/bin/vscode-eslint-language-server";
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
        experimental = { };
        format = {
          enable = false;
        };
        nodePath = "";
        problems = {
          shortenToSingleLine = false;
        };
        quiet = false;
        rulesCustomizations = [ ];
        run = "onType";
        validate = "on";
      };
    };
    tailwindcss-ls = {
      command = "${pkgs.vscode-langservers-extracted}/bin/tailwindcss-language-server";
      args = [ "--stdio" ];
      format.enable = false;
    };
    vscode-css-language-server = {
      command = "${pkgs.vscode-langservers-extracted}/bin/vscode-css-language-server";
      args = [ "--stdio" ];
      config = {
        css = {

          validate = {
            enable = true;
          };
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
    };
    vscode-json-language-server = {
      command = "${pkgs.vscode-langservers-extracted}/bin/vscode-json-language-server";
      args = [ "--stdio" ];
      config = {
        json = {
          format = {
            enable = true;
          };
          validate = {
            enable = true;
          };
        };
        provideFormatter = true;
      };
    };
  };
in
{
  options.local.langServers = {
    enable = mkEnableOption "My Lang Servers";

    enableHelixIntegration = (lib.mkEnableOption "Helix Integration") // {
      default = true;
    };
  };

  config = mkIf (cfg.enable && cfg.enableHelixIntegration) {
    programs.helix.languages.language-server = langServers;
    programs.helix.languages.language = [
      {
        name = "clojure";
        auto-format = true;
        language-servers = [ "clojure" ];
        formatter.command = "${pkgs.zprint}/bin/zprint";
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
        formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
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
          "typescript-language-server"
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
          "typescript-language-server"
          "tailwindcss-language-server"
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
          "typescript-language-server"
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
          "typescript-language-server"
          "tailwindcss-language-server"
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
          "vscode-css-language-server"
          "emmet-ls"
        ];
      }
    ];
  };
}
