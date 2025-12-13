{
  config,
  pkgs,
  lib,
  ...
}:
let

  inherit (pkgs)
    stdenvNoCC
    makeWrapper
    buildNpmPackage
    fetchzip
    writableTmpDirAsHomeHook
    versionCheckHook
    importNpmLock
    ;

  cfg = config.local.claude;

  # Run ./update.nu to update the coordinates to the latest stable version
  coords = import ./coords.nix;
  version = coords.version;
  downloadable = coords.platforms.${stdenvNoCC.hostPlatform.system};

  claudeCode = stdenvNoCC.mkDerivation {
    pname = "claude-code";
    inherit version;
    src = builtins.fetchurl downloadable;

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      install -m 755 $src $out/bin/claude

      runHook postInstall
    '';
  };

  claudeCodeAcp = buildNpmPackage rec {
    pname = "claude-code-acp";
    version = "0.12.4";

    src = fetchzip {
      url = "https://registry.npmjs.org/@zed-industries/claude-code-acp/-/claude-code-acp-${version}.tgz";
      hash = "sha256-264fukn1TxHQxNSxHTx9/ym46592pMxnGUdv0wt/09s=";
    };

    npmDeps = importNpmLock {
      package = lib.importJSON "${src}/package.json";
      packageLock = lib.importJSON ''${builtins.fetchurl {
        url = "https://raw.githubusercontent.com/zed-industries/claude-code-acp/refs/tags/v${version}/package-lock.json";
        sha256 = "087fh1fd49f6xqnzmrcbm5cnql4fza1wibvw57aw1hvi9fsjq94p";
      }}'';
    };

    npmConfigHook = importNpmLock.npmConfigHook;

    dontNpmBuild = true;
  };

in
{
  options.local.claude = {
    enable = lib.mkEnableOption "claude";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      claudeCode
      claudeCodeAcp
    ];
  };
}
