{
  language = [
    {
      auto-format = true;
      formatter = {
        args = [
          "--parser"
          "typescript"
        ];
        command = "prettier";
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
      name = "typescript";
    }
    {
      auto-format = true;
      formatter = {
        args = [
          "--parser"
          "typescript"
        ];
        command = "prettier";
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
      name = "tsx";
    }
    {
      auto-format = true;
      formatter = {
        args = [
          "--parser"
          "typescript"
        ];
        command = "prettier";
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
      name = "javascript";
    }
    {
      auto-format = true;
      formatter = {
        args = [
          "--parser"
          "typescript"
        ];
        command = "prettier";
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
      name = "jsx";
    }
    {
      auto-format = true;
      formatter = {
        args = [
          "--parser"
          "json"
        ];
        command = "prettier";
      };
      name = "json";
    }
    {
      auto-format = true;
      formatter = {
        args = [
          "--parser"
          "html"
        ];
        command = "prettier";
      };
      language-servers = [
        "vscode-html-language-server"
        "emmet-ls"
      ];
      name = "html";
    }
    {
      auto-format = true;
      formatter = {
        args = [
          "--parser"
          "css"
        ];
        command = "prettier";
      };
      language-servers = [
        "vscode-css-language-server"
        "emmet-ls"
      ];
      name = "css";
    }
  ];
  language-server = {
    efm = {
      command = "efm-langserver";
    };
    eslint = {
      args = [ "--stdio" ];
      command = "vscode-eslint-language-server";
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
      args = [ "--stdio" ];
      command = "tailwindcss-language-server";
    };
    vscode-css-language-server = {
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
}
