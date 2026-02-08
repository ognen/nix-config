{
  lib,
  buildNpmPackage,
  fetchzip,
  importNpmLock,
  nushell,
  writeShellScript,
}:
let
  coords = import ./acp-coords.nix;

  src = fetchzip {
    inherit (coords.src) url hash;
  };
in
buildNpmPackage {
  pname = "claude-code-acp";
  inherit (coords) version;
  inherit src;

  npmDeps = importNpmLock {
    package = lib.importJSON "${src}/package.json";
    packageLock = lib.importJSON ''${builtins.fetchurl {
      inherit (coords.packageLock) url;
      sha256 = coords.packageLock.hash;
    }}'';
  };

  npmConfigHook = importNpmLock.npmConfigHook;
  dontNpmBuild = true;

  passthru.updateScript = writeShellScript "update-claude-code-acp" ''
    set -euo pipefail
    cd dotfiles/modules/claude
    ${lib.getExe nushell} ./update-acp.nu
  '';
}
