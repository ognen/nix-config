{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.local.emacs;
  inherit (lib) mkEnableOption mkIf;
  emacsIcons = pkgs.fetchFromGitHub {
    owner = "emacsfodder";
    repo = "emacs-icons-project";
    rev = "47678252818b11bc9e0f841119220e26e8f5ca20";
    hash = "sha256-DoVpo0bgL5l/HfXZWVr7ucYEFjlBA5/4X9Q5nqChPqw=";
  };
  icon = "${emacsIcons}/EmacsVapor.icns";
in
{
  options.local.emacs.enable = mkEnableOption "Emacs";

  # TODO emacs packages (maybe)
  # TODO direnv integration
  config = mkIf cfg.enable {
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
    };

  };
}
