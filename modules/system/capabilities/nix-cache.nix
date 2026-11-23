{ config, lib, root, ... }:

with lib;

let
  cfg = config.modules.nix-cache;
in
{
  options.modules.nix-cache = {
    enable = mkEnableOption "the Nix binary cache server";
  };

  config = mkIf cfg.enable {
    services.harmonia.cache = {
      enable = true;
      settings.bind = "127.0.0.1:5000";
      signKeyPaths = [ "/var/lib/secrets/nixcache.secret" ];
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = (import (root + "/data/email-accounts.nix")).Personal.address;
    };

    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      virtualHosts."nixcache.krishy.dev" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:5000";
          # Stream NARs without buffering large responses to disk
          extraConfig = "proxy_buffering off;";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
