{ lib }:

# Return KDE's user-places.xbel as a string
#
# Usage:
#   xdg.dataFile."user-places.xbel".text =
#     import (root + "/utils/gen-user-places-xbel.nix") { inherit lib; } {
#       places = [
#         { Home = "file:///home/krishnan"; }
#         { School = "file:///home/krishnan/School"; }
#         {
#           "Project Folder" = {
#             href = "file:///home/krishnan/Videos/Kdenlive/";
#             icon = "folder-favorites";
#             metadata.OnlyInApp = "kdenlive";
#           };
#         }
#       ];
#     };
#
# Standard English place names below get KDE's icons and isSystemItem flag
# (which enables translation); other names get inode-directory by default.
# Icons and KDE metadata can be overridden per place. Metadata values may be
# strings, booleans, integers, or null (omit the element), e.g. IsHidden = true,
# isSystemItem = null, or ID = "1729404602/0" to retain an existing ID.
# Hrefs are already-encoded URIs; this function escapes XML, not URLs.
#
# Root metadata overrides group visibility and KDE's initialization markers.
# Device entries can be supplied as separators = [ { UDI = "..."; uuid = "..."; } ];
# they are emitted after the bookmarks, with isSystemItem = true by default.
# KDE also discovers devices at runtime; hardware entries need not be declared.
# Use xdg.dataFile."user-places.xbel".text to manage the result declaratively.
{ places, metadata ? { }, separators ? [ ] }:

let
  # Normalize and validate places before rendering them
  entries =
    let
      toEntries = entry: if
        builtins.isAttrs entry && builtins.length (builtins.attrNames entry) == 1
      then
        lib.attrsToList entry
      else
        throw "gen-user-places-xbel: each places list entry must be a single-entry attribute set";

      result =
        if builtins.isAttrs places then lib.attrsToList places else lib.concatMap toEntries places;
    in
    if lib.allUnique (builtins.catAttrs "name" result) then
      result
    else
      throw "gen-user-places-xbel: place names must be unique";

  validateMetadata = values: lib.mapAttrs (
    name: value: if builtins.match "[A-Za-z_][A-Za-z0-9_.-]*" name == null then
      throw "gen-user-places-xbel: invalid metadata element name '${name}'"
    else if builtins.isString value || builtins.isBool value || builtins.isInt value then
      value
    else
      throw "gen-user-places-xbel: metadata '${name}' must be a string, boolean, integer, or null"
  ) (lib.filterAttrs (_: value: value != null) values);

  defaultIcons = {
    Home = "user-home";
    Desktop = "user-desktop";
    Documents = "folder-documents";
    Downloads = "folder-downloads";
    Music = "folder-music";
    Pictures = "folder-pictures";
    Videos = "folder-videos";
    Network = "folder-network";
    Trash = "user-trash";
    "Recent Files" = "document-open-recent";
    "Recent Locations" = "folder-open-recent";
  };

  # Attribute whitespace must survive XML's attribute-value normalization.
  escapeAttribute = value: lib.replaceStrings [ "\t" "\n" "\r" ] [ "&#9;" "&#10;" "&#13;" ] (
    lib.escapeXML value
  );

  renderMetadata = indent: values: lib.concatMapAttrsStringSep "\n" (
    name: value:
    let
      text = if builtins.isBool value then lib.boolToString value else toString value;
    in
    "${indent}<${name}>${lib.escapeXML text}</${name}>"
  ) (validateMetadata values);

  renderBookmark = name: { href, icon ? defaultIcons.${name} or "inode-directory", metadata ? { } }:
  let
    # KDE treats IDs as opaque strings
    # Hash the identity, not its position, so reordering or inserting places does not change other bookmarks' IDs
    kdeMetadata = {
      ID = "nix-${builtins.hashString "sha256" (builtins.toJSON [ name href ])}";
    } // lib.optionalAttrs (defaultIcons ? ${name}) { isSystemItem = true; } // metadata;
  in
  ''
     <bookmark href="${escapeAttribute href}">
      <title>${lib.escapeXML name}</title>
      <info>
       <metadata owner="http://freedesktop.org">
        <bookmark:icon name="${escapeAttribute icon}"/>
       </metadata>
       <metadata owner="http://www.kde.org">
    ${renderMetadata "    " kdeMetadata}
       </metadata>
      </info>
     </bookmark>
  '';

  renderSeparator = values: ''
     <separator>
      <info>
       <metadata owner="http://www.kde.org">
    ${renderMetadata "    " ({ isSystemItem = true; } // values)}
       </metadata>
      </info>
     </separator>
  '';

  rootMetadata = {
    kde_places_version = 4;
    GroupState-Places-IsHidden = false;
    GroupState-Remote-IsHidden = false;
    GroupState-Devices-IsHidden = false;
    GroupState-RemovableDevices-IsHidden = false;
    GroupState-Tags-IsHidden = false;
    GroupState-RecentlySaved-IsHidden = false;
    GroupState-SearchFor-IsHidden = false;
    # These mark initialization as complete, preventing KDE from adding defaults
    # that were deliberately left out of places (including Baloo search entries)
    withRecentlyUsed = true;
    withBaloo = true;
  } // metadata;
in
''
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE xbel>
  <xbel xmlns:bookmark="http://www.freedesktop.org/standards/desktop-bookmarks" xmlns:kdepriv="http://www.kde.org/kdepriv" xmlns:mime="http://www.freedesktop.org/standards/shared-mime-info">
   <info>
    <metadata owner="http://www.kde.org">
  ${renderMetadata "   " rootMetadata}
    </metadata>
   </info>
  ${
    lib.concatMapStrings (
      { name, value }:
      renderBookmark name (if builtins.isString value then { href = value; } else value)
    ) entries
  }${lib.concatMapStrings renderSeparator separators}</xbel>
''
