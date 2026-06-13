{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.gaming;
in
{
  # It might be better to have options specific to each game
  # But for now, it's either all games enabled or no games enabled
  # Since that's how this module is used by the systems
  options.modules.gaming = {
    enable = mkEnableOption "Enable gaming-related packages";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
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
      prismlauncher  # minecraft
      #sauerbraten
    ];
  };
}
