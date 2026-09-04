{ config, lib, ... }:

with lib;

let
  cfg = config.modules.seed-file;
in
{
  options.modules.seed-file = {
    seedFiles = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "Unique name used for the home-manager activation entry.";
            };
            file = mkOption {
              type = types.str;
              description = "Destination file. Absolute, or relative to the home directory.";
              example = ".config/Zulip/config/settings.json";
            };
            source = mkOption {
              type = types.path;
              description = "Store path to copy when the destination is missing or a symlink.";
            };
          };
        }
      );
      default = [ ];
      description = "Seed mutable config files on activation, when read-only declarative config is not an option";
      example = [
        {
          name = "seedZulipSettings";
          file = ".config/Zulip/config/settings.json";
          source = ./settings.json;
        }
      ];
    };
  };

  config = mkIf (cfg.seedFiles != [ ]) {
    home.activation = listToAttrs (
      map (
        { name, file, source }:
        let
          liveFile = if hasPrefix "/" file then file else "${config.home.homeDirectory}/${file}";
        in
        {
          inherit name;
          value = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            mkdir -p "$(dirname ${escapeShellArg liveFile})"
            if [ ! -e ${escapeShellArg liveFile} ] || [ -L ${escapeShellArg liveFile} ]; then
              install -Dm644 ${source} ${escapeShellArg liveFile}
            fi
          '';
        }
      ) cfg.seedFiles
    );
  };
}
