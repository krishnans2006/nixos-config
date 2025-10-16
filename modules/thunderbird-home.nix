{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.thunderbird;
in
{
  options.modules.thunderbird = {
    enable = mkEnableOption "Enable Thunderbird for email accounts";
  };

  config = mkIf cfg.enable {
    accounts.email.accounts = {
      "Personal" = {
        primary = true;
        realName = "Krishnan Shankar";
        address = "krishnans2006@gmail.com";
        flavor = "gmail.com";
        thunderbird = {
          enable = true;
          settings = id: {
            # OAuth2
            "mail.server.server_${id}.authMethod" = 10;
            "mail.smtpserver.smtp_${id}.authMethod" = 10;
          };
        };
      };
      "Illinois" = {
        realName = "Krishnan Shankar";
        address = "ks128@illinois.edu";
        flavor = "gmail.com";
        thunderbird = {
          enable = true;
          settings = id: {
            # OAuth2
            "mail.server.server_${id}.authMethod" = 10;
            "mail.smtpserver.smtp_${id}.authMethod" = 10;
          };
        };
      };
    };
    programs.thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
      };
      settings = {
        "general.useragent.override" = "";
        "privacy.donottrackheader.enabled" = true;
        # Allow remote content
        "mailnews.message_display.disable_remote_image" = false;
      };
    };
  };
}
