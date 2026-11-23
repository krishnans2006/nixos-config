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
    systemd.services.nix-cache-update = {
      description = "Build and publish daily Nix cache updates";
      startAt = "*-*-* 03:00:00";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" "nginx.service" ];
      path = [
        pkgs.bash
        pkgs.git
        pkgs.nh
        pkgs.openssh
        config.nix.package
      ];
      environment = {
        GIT_SSH_COMMAND = "ssh -o BatchMode=yes -o StrictHostKeyChecking=yes";
        GIT_TERMINAL_PROMPT = "0";
        NH_ROM = "off";
      };
      serviceConfig = {
        Type = "oneshot";
        User = config.modules.primary-user.username;
        NoNewPrivileges = true;
        StateDirectory = "nix-cache-update";
        StateDirectoryMode = "0700";
        RuntimeDirectory = "nix-cache-update";
        RuntimeDirectoryMode = "0700";
      };
      script = ''
        exec bash ${root + "/scripts/update-cache.sh"} \
          git@github.com:krishnans2006/nixos-config.git \
          ${root + "/scripts/build-cache.sh"}
      '';
    };

    systemd.timers.nix-cache-update.timerConfig.Persistent = true;
  };
}
