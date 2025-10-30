{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.local.emacs;
  inherit (lib) mkEnableOption mkMerge mkIf;
  emacsIcons = pkgs.fetchFromGitHub {
    owner = "emacsfodder";
    repo = "emacs-icons-project";
    rev = "47678252818b11bc9e0f841119220e26e8f5ca20";
    hash = "sha256-DoVpo0bgL5l/HfXZWVr7ucYEFjlBA5/4X9Q5nqChPqw=";
  };
  icon = "${emacsIcons}/EmacsVapor.icns";

  toEmacsCustomValue =
    value:
    let
      t = builtins.typeOf value;
      esc = lib.escape [ ''"'' ];
    in
    if t == "bool" then
      toString value
    else if t == "int" then
      toString value
    else if t == "string" then
      ''"${esc (toString value)}"''
    else
      throw "Unsupported type '${t}' for value: ${builtins.toJSON value}";

  customizations = lib.mapAttrsToList (a: v: "'(${a} ${toEmacsCustomValue v})") cfg.customizations;
in
{
  options.local.emacs = {
    enable = mkEnableOption "Emacs";

    customizations = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      description = "attribute-value pairs that end up as (customize-set-variables) in a config file cusom-from-nix-home-manager.el";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      programs.emacs = {
        enable = true;
        package = pkgs.emacs-macport.overrideAttrs (
          final: previous: {
            configureFlags = previous.configureFlags ++ [ "--with-mac-metal" ];

            preConfigure = (previous.preConfigure or "") + ''
              # Wanna use my favorite icon
              cp ${icon} mac/Emacs.app/Contents/Resources/Emacs.icns
            '';
          }
        );

        extraPackages = epkgs: [
          epkgs.treesit-grammars.with-all-grammars
        ];
      };
    })

    (mkIf (customizations != [ ]) {
      xdg.configFile = {
        "emacs/custom-from-nix-home-manager.el".text = ''
          (custom-set-variables
            ${(lib.concatStringsSep "\n  " customizations)}
          )
        '';
      };
    })
  ];
}
