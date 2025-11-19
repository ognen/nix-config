{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.local.langServers;
  inherit (cfg) flakePath;
  inherit (lib) mkEnableOption mkMerge mkIf;
  langServers = {
    nixd = import ./nixd.nix { inherit pkgs flakePath lib; };
    efm = import ./efm.nix { inherit pkgs; };
    json = import ./json.nix { inherit pkgs; };
    tailwind = import ./tailwind.nix { inherit pkgs; };
    eslint = import ./eslint.nix { inherit pkgs; };
    css = import ./css.nix { inherit pkgs; };
    clojure-lsp = import ./clojure-lsp.nix { inherit pkgs; };
    typescript = import ./typescript.nix { inherit pkgs; };
    html = import ./html.nix { inherit pkgs; };
    emmet-ls = import ./emmet.nix { inherit pkgs; };
  };

  pkgsFromConfig =
    ls:
    lib.unique (
      builtins.concatMap (s: if (s ? package) then [ s.package ] else s.packages) (builtins.attrValues ls)
    );
  package = pkgs.symlinkJoin {
    name = "Language Servers";
    paths = pkgsFromConfig langServers;
  };

  helixConfig = import ./helix-config.nix { inherit package lib langServers; };

  emacsCustomizations = lib.foldl (
    customizations: lsc:
    if lsc ? emacsCustomizations then
      (lib.mergeAttrs customizations lsc.emacsCustomizations)
    else
      customizations
  ) { } (builtins.attrValues langServers);

  emacsConfiguraiton = lib.foldl (
    config: lsc: if lsc ? emacsConfiguration then config + "\n" + lsc.emacsConfiguration else config
  ) "" (builtins.attrValues langServers);

in
{
  options.local.langServers = {
    enable = mkEnableOption "My Lang Servers";

    enableHelixIntegration = (lib.mkEnableOption "Helix Integration") // {
      default = true;
    };

    enableEmacsIntegration = (lib.mkEnableOption "Emacs Integration") // {
      default = true;
    };

    flakePath = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path to the root of the flake containing the overall configuration(s).
      '';
    };
  };

  config = mkMerge [
    (mkIf (cfg.enableHelixIntegration && !cfg.enableEmacsIntegration) {
      programs.helix.extraPackages = [ package ];
    })
    (mkIf (cfg.enableHelixIntegration) helixConfig)
    # For emacs, we're just exposing the language servers in the environmengt as
    # lsp-mode is good at picking up defaults
    (mkIf (cfg.enableEmacsIntegration) {
      home.packages = [ package ];

      local.emacs.customizations = emacsCustomizations;
      local.emacs.configuration = emacsConfiguraiton;
    })
  ];
}
