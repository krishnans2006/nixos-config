{ config, lib, ... }:

with lib;

let
  cfg = config.modules.thunderbird;

  emailAccounts = import (root + "/data/email-accounts.nix");
in
{
  options.modules.thunderbird = {
    enable = mkEnableOption "Enable Thunderbird for email accounts";
    #
  };

  config = mkIf cfg.enable {
    accounts.email.accounts = emailAccounts;

    programs.thunderbird = {
      enable = true;
      profiles.default.isDefault = true;
      settings = {
        "general.useragent.override" = "";
        "privacy.donottrackheader.enabled" = true;
        # Allow remote content
        "mailnews.message_display.disable_remote_image" = false;
      };
    };
  };
}
