{
  pkgs,
}:
let
  pkg = pkgs.efm-langserver;
in
{
  packages = [
    pkg
    pkgs.prettierd
    pkgs.prettier
  ];
  command = "${pkg}/bin/efm-langserver";

  configFiles = {
    "efm-langserver/config.yaml".text = ''
      version: 2
      log-file: /Users/oivanovs/.cache/efm.log
      log-level: 1
      root-markers:
      - .git/
      lint-debounce: 1s

      tools:
        json-prettier: &json-prettier
            format-command: '${pkgs.prettier}/bin/prettier ''${--tab-width:tabWidth} --parser json'

        html-prettier: &html-prettier
          format-command: '${pkgs.prettier}/bin/prettier ''${--tab-width:tabWidth} ''${--single-quote:singleQuote} --parser html'

        css-prettier: &css-prettier
          format-command: '${pkgs.prettier}/bin/prettier ''${--tab-width:tabWidth} ''${--single-quote:singleQuote} --parser css'

        prettierd: &prettierd
          format-command: >
            ${pkgs.prettierd}/bin/prettierd ''${INPUT} ''${--range-start=charStart} ''${--range-end=charEnd} \
              ''${--tab-width=tabSize}
          format-stdin: true
          root-markers:
            - .prettierrc
            - .prettierrc.json
            - .prettierrc.js
            - .prettierrc.yml
            - .prettierrc.yaml
            - .prettierrc.json5
            - .prettierrc.mjs
            - .prettierrc.cjs
            - .prettierrc.toml

      languages:
      css:
        - <<: *css-prettier

      json:
         - <<: *json-prettier

      html:
        - <<: *html-prettier

      javascript:
        - <<: *prettierd

      typescript:
        - <<: *prettierd

      typescriptreact:
        - <<: *prettierd

      javascriptreact:
        - <<: *prettierd
    '';
  };
}
