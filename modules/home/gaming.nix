{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.gaming;
in
{
  options.modules.gaming = {
    enableLutris = mkEnableOption "Lutris";
    enableMinecraft = mkEnableOption "Minecraft via Prism Launcher";
  };

  config = {
    home.packages = mkMerge [
      (mkIf cfg.enableLutris [
        (pkgs.lutris-free.override {
          # Override the underlying lutris package
          lutris = pkgs.lutris.override {
            # Intercept buildFHSEnv to modify target packages
            buildFHSEnv = args: pkgs.buildFHSEnv (args // {
              multiPkgs = envPkgs:
                let
                  # Fetch original package list
                  originalPkgs = args.multiPkgs envPkgs;

                  # Disable tests for openldap
                  customLdap = envPkgs.openldap.overrideAttrs (_: { doCheck = false; });
                in
                # Replace broken openldap with the custom one
                builtins.filter (p: (p.pname or "") != "openldap") originalPkgs ++ [ customLdap ];
            });
          };
        })
      ])

      (mkIf cfg.enableMinecraft [
        pkgs.prismlauncher
      ])
    ];
  };
}
