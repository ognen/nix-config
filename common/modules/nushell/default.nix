{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.nushell;
  setEnvironment = config.system.build.setEnvironment;
  inherit (lib) mkIf mkEnableOption;

  captureEnv = pkgs.writeTextDir "share/nushell/capture-env.nu" (builtins.readFile ./capture-env.nu);
in
{
  options.local.nushell = {
    enable = mkEnableOption "nushell";
  };

  config = mkIf (cfg.enable) {
    environment.systemPackages = [
      pkgs.nushell
    ];

    environment.shells = [ pkgs.nushell ];

    # Packages that ship nushell modules put them in share/nushell, and both
    # system.path and the per-user profiles under /etc/profiles are buildEnvs
    # filtered by environment.pathsToLink — which by default keeps only /bin
    # and a handful of /share subdirectories. Without this, every nushell
    # module installed through environment.systemPackages or home.packages is
    # silently dropped from the profile and NU_LIB_DIRS resolves to nothing.
    environment.pathsToLink = [ "/share/nushell" ];

    environment.etc = {
      "nushell/capture-env.nu".source = "${captureEnv}/share/nushell/capture-env.nu";
      "nushell/nix-env.nu".text = ''
        use /etc/nushell/capture-env.nu

        if ($env.__NIX_DARWIN_SET_ENVIRONMENT_DONE? != "1") {
          capture-env ${setEnvironment} | load-env
        }
      '';

    };
  };

}
