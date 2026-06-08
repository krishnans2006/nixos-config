{ config, lib, ... }:

with lib;

let
  cfg = config.modules.impermanence;
in
{
  options.modules.impermanence = {
    enable = mkEnableOption "Enable base impermanence persistence configuration";

    # Usage in modules:
    # config = {
    #   modules.impermanence.persistDirs = [ ".config/..." ];
    # };
    persistDirs = mkOption {
      type = with types; listOf (either str attrs);
      default = [ ];
      description = "List of directories to persist in home.";
      # apply = unique;
    };
    persistFiles = mkOption {
      type = with types; listOf (either str attrs);
      default = [ ];
      description = "List of files to persist in home.";
      # apply = unique;
    };
  };

  config = mkMerge [
    # Since many modules define paths to be persisted (using home.persistence."/persist")
    # We need to explicitly disable "/persist" if impermanence isn't enabled
    # So that this doesn't cause issues when impermanence is disabled
    (mkIf (!cfg.enable) {
      home.persistence."/persist".enable = mkForce false;
    })

    (mkIf cfg.enable {
      home.persistence."/persist" = {
        directories = cfg.persistDirs ++ [
          "NixOS"

          "Documents"
          "Downloads"
          "Music"
          "Pictures"
          "Videos"

          "School"
          "Tech"

          { directory = ".ssh"; mode = "0700"; }
          { directory = ".gnupg"; mode = "0700"; }
          ".local/share/atuin"
          ".local/share/zoxide"

          ".config/vesktop/sessionData"
          ".config/vesktop/settings"  # Synced settings for plugins, etc.

          ".config/Element/IndexedDB"  # E2E Keys, auth
          ".config/Element/EventStore"  # Seshat database for search
        ];
        files = cfg.persistFiles ++ [
          # Needed to decrypt secrets at boot
          ".config/sops/age/keys.txt"

          ".config/vesktop/settings.json"   # Vesktop settings (titlebar, tray, etc.)

          ".config/Element/electron-config.json"
        ];
      };
    })
  ];
}
