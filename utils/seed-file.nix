{ lib, config }:

with lib;

# Generate home.activation entries that copy store files into the live home
# directory when missing (or always when force = true). Use when an app rewrites
# its config at runtime and a read-only xdg.configFile symlink would break it.
#
# Usage:
#   home.activation = import "${root}/utils/seed-file.nix" { inherit lib config; } [
#     {
#       name = "seedZulipSettings";
#       file = ".config/Zulip/config/settings.json";
#       source = ./settings.json;
#     }
#   ];
seedFiles: mkMerge (
  map (
    { name, file, source, force ? false }:
    let
      liveFile = if hasPrefix "/" file then file else "${config.home.homeDirectory}/${file}";
    in
    {
      ${name} = lib.hm.dag.entryAfter [ "writeBoundary" ] (
        if force then
          ''
            mkdir -p "$(dirname ${escapeShellArg liveFile})"
            install -Dm644 ${source} ${escapeShellArg liveFile}
          ''
        else
          ''
            mkdir -p "$(dirname ${escapeShellArg liveFile})"
            if [ ! -e ${escapeShellArg liveFile} ] || [ -L ${escapeShellArg liveFile} ]; then
              install -Dm644 ${source} ${escapeShellArg liveFile}
            fi
          ''
      );
    }
  ) seedFiles
)
