{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.local.circleci;

  # Pinned by ./update.sh (run as part of update-flake).
  sources = lib.importJSON ./sources.json;
  src = sources.systems.${pkgs.stdenv.hostPlatform.system};

  circleci = pkgs.stdenvNoCC.mkDerivation {
    pname = "circleci";
    inherit (sources) version;

    src = pkgs.fetchurl { inherit (src) url hash; };
    sourceRoot = ".";

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 circleci $out/bin/circleci
      cp -r share $out/share
      runHook postInstall
    '';

    meta = {
      description = "Official command-line tool for CircleCI";
      homepage = "https://cli.circleci.com";
      license = lib.licenses.mit;
      mainProgram = "circleci";
      platforms = builtins.attrNames sources.systems;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    };
  };
in
{
  options.local.circleci = {
    enable = mkEnableOption "circleci";
  };

  config = mkIf cfg.enable {
    home.packages = [ circleci ];
  };
}
