{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.systemd-persist;
in
{
  options.modules.systemd-persist = {
    persistFiles = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "Unique name used for systemd user units (e.g. element-electron-config).";
            };
            file = mkOption {
              type = types.str;
              description = "File to sync. Absolute, or relative to the home directory.";
              example = ".config/Element/electron-config.json";
            };
          };
        }
      );
      default = [ ];
      description = "Files to sync to /persist via systemd user services; use this when an app atomically renames over the path";
      example = [
        {
          name = "element-electron-config";
          file = ".config/Element/electron-config.json";
        }
      ];
    };
  };

  config = mkIf (cfg.persistFiles != [ ]) {
    systemd.user.services = listToAttrs (
      concatMap (
        { name, file }:
        let
          liveFile = if hasPrefix "/" file then file else "${config.home.homeDirectory}/${file}";
          persistFile = "/persist${liveFile}";
          fileName = baseNameOf liveFile;
          save = pkgs.writeShellScript "${name}-save" ''
            set -eu
            if [ -f ${escapeShellArg liveFile} ]; then
              mkdir -p "$(dirname ${escapeShellArg persistFile})"
              cp -a ${escapeShellArg liveFile} ${escapeShellArg persistFile}.tmp
              mv -f ${escapeShellArg persistFile}.tmp ${escapeShellArg persistFile}
            fi
          '';
        in
        [
          {
            name = "${name}-restore";
            value = {
              Unit.Description = "Restore ${fileName} from persist";
              Service = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart = pkgs.writeShellScript "${name}-restore" ''
                  set -eu
                  mkdir -p "$(dirname ${escapeShellArg liveFile})"
                  if [ -f ${escapeShellArg persistFile} ]; then
                    cp -a ${escapeShellArg persistFile} ${escapeShellArg liveFile}
                  fi
                '';
                ExecStop = "${save}";
              };
              Install.WantedBy = [ "default.target" ];
            };
          }
          {
            name = "${name}-watch";
            value = {
              Unit = {
                Description = "Persist ${fileName} when it changes";
                After = [ "${name}-restore.service" ];
                Requires = [ "${name}-restore.service" ];
              };
              Service = {
                ExecStart = pkgs.writeShellScript "${name}-watch" ''
                  set -eu
                  dir=${escapeShellArg (dirOf liveFile)}
                  mkdir -p "$dir"
                  ${save}
                  ${pkgs.inotify-tools}/bin/inotifywait -m -e close_write,moved_to,create --format '%f' "$dir" |
                    while read -r f; do
                      if [ "$f" = ${escapeShellArg fileName} ]; then
                        ${save}
                      fi
                    done
                '';
                Restart = "on-failure";
                RestartSec = "2";
              };
              Install.WantedBy = [ "default.target" ];
            };
          }
        ]
      ) cfg.persistFiles
    );
  };
}
