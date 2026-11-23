{ config, lib, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.nix-cache-update;
in
{
  options.modules.nix-cache-update = {
    enable = mkEnableOption "daily Nix cache updates";
  };

  config = mkIf cfg.enable {
    sops.secrets."nix-cache/update-pat" = {
      sopsFile = root + "/secrets/nix-cache.yaml";
    };

    systemd.services.nix-cache-update = {
      description = "Build and publish daily Nix cache updates";
      startAt = "*-*-* 03:00:00";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" "nginx.service" ];
      path = [
        pkgs.bash
        pkgs.git
        pkgs.nh
        config.nix.package
      ];
      environment = {
        GIT_CONFIG_COUNT = "1";
        GIT_CONFIG_KEY_0 = "http.https://github.com/krishnans2006/.extraHeader";
        GIT_TERMINAL_PROMPT = "0";
        NH_ROM = "off";
      };
      serviceConfig = {
        Type = "oneshot";
        User = config.modules.primary-user.username;
        NoNewPrivileges = true;
        LoadCredential = "github-pat:${config.sops.secrets."nix-cache/update-pat".path}";
        StateDirectory = "nix-cache-update";
        StateDirectoryMode = "0700";
        RuntimeDirectory = "nix-cache-update";
        RuntimeDirectoryMode = "0700";
      };
      script = ''
        auth=$(printf 'krishnans2006:%s' "$(<"$CREDENTIALS_DIRECTORY/github-pat")" | base64 -w0)
        export GIT_CONFIG_VALUE_0="Authorization: Basic $auth"
        exec bash ${root + "/scripts/update-cache.sh"} \
          https://github.com/krishnans2006/nixos-config.git \
          ${root + "/scripts/build-cache.sh"}
      '';
    };

    systemd.timers.nix-cache-update.timerConfig.Persistent = true;
  };
}
