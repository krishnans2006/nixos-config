{ config, lib, ... }:

with lib;

let
  cfg = config.modules.impermanence;
in
{
  options.modules.impermanence = {
    enable = mkEnableOption "Enable base impermanence persistence configuration";
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
        directories = [
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
          ".local/share/direnv"
          ".local/share/atuin"
          ".local/share/zoxide"
          ".local/share/klipper"  # Clipboard
          ".local/share/zed"
          ".local/share/flatpak"
          ".local/share/baloo"  # File Indexing
          ".local/share/kwalletd"  # Wallet

          ".config/vesktop/sessionData"
          ".config/vesktop/settings"  # Synced settings for plugins, etc.
        ];
        files = [
          # Needed to decrypt secrets at boot
          ".config/sops/age/keys.txt"

          ".config/vesktop/settings.json"   # Vesktop settings (titlebar, tray, etc.)
        ];
      };
    })
  ];
}
