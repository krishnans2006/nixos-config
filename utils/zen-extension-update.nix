{ lib, pkgs, ... }:

with lib;

# Generate home { file, activation } attribute sets to declaratively manage
# WebExtension storage for Zen Browser.
#
# Gecko imports `browser-extension-data/<id>/storage.js` into IndexedDB on first run.
# When Zen is closed, this clears the extension's IndexedDB cache and resets the
# migration preference so Gecko automatically re-imports the updated JSON on next launch.
# If Zen is running, it safely skips the cleanup to prevent disrupting active extension storage.
#
# Usage:
#   home = import (root + "/utils/zen-extension-update.nix") { inherit lib pkgs; } [
#     {
#       id = extensions.foxy-gestures.id;
#       json = ../../../custom/foxy-gestures.json;
#     }
#   ];
extensions:
let
  profileDir = ".config/zen/default";

  mkFileEntry =
    { id, json, ... }:
    nameValuePair "${profileDir}/browser-extension-data/${id}/storage.js" { source = json; };

  mkActivationEntry =
    { id, name ? null, ... }:
    let
      sanitizedId = replaceStrings [ "{" "}" "@" "." ":" ] [ "" "" "-" "-" "-" ] id;
      actName = if name != null then name else "zen-browser-extension-update-${sanitizedId}";
    in
    nameValuePair actName (
      hm.dag.entryAfter [ "writeBoundary" ] ''
        PROFILE_DIR="$HOME/${profileDir}"
        PREFS_FILE="$PROFILE_DIR/prefs.js"
        LOCK_FILE="$PROFILE_DIR/.parentlock"

        if [ -d "$PROFILE_DIR" ] && [ -f "$PREFS_FILE" ]; then
          if [ -f "$LOCK_FILE" ] && ${getExe pkgs.lsof} "$LOCK_FILE" >/dev/null 2>&1; then
            echo "zen-browser-extension-update: Zen Browser appears to be running; skipping storage cleanup for ${id}."
            echo "zen-browser-extension-update: Close Zen Browser and rebuild to apply extension storage changes."
          else
            EXT_ID=${escapeShellArg id}
            EXT_UUID=$(grep '"extensions.webextensions.uuids"' "$PREFS_FILE" 2>/dev/null | sed -n "s/.*\\\\\"$EXT_ID\\\\\":\\\\\"\([^\\\\\"]*\).*/\1/p")

            if [ -n "$EXT_UUID" ]; then
              rm -rf "$PROFILE_DIR/storage/default/moz-extension+++"$EXT_UUID* 2>/dev/null || true
            fi

            sed -i "/ExtensionStorageIDB\.migrated\.$EXT_ID/d" "$PREFS_FILE" 2>/dev/null || true
          fi
        fi
      ''
    );
in
{
  file = listToAttrs (map mkFileEntry extensions);
  activation = listToAttrs (map mkActivationEntry extensions);
}
