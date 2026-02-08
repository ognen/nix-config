{
  stdenvNoCC,
  lib,
  nushell,
  writeShellScript,
}:
let
  coords = import ./coords.nix;
  version = coords.version;
  downloadable = coords.platforms.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation {
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

  passthru.updateScript = writeShellScript "update-claude-code" ''
    set -euo pipefail
    cd dotfiles/modules/claude
    ${lib.getExe nushell} ./update.nu
  '';
}
