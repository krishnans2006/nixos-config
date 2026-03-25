{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.packages.firefox;
in
{
  options.modules.packages.firefox = {
    enable = mkEnableOption "Enable Firefox web browser";
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;

      profiles.default = {
        id = 0;
        name = "default";
        isDefault = true;
        settings = {
          "app.update.auto" = false;
          "browser.bookmarks.restore_default_bookmarks" = false;
          "browser.contentblocking.category" = "strict";
          "browser.ctrlTab.sortByRecentlyUsed" = false;
          "browser.download.dir" = "/home/krishnan/Downloads/Firefox";
          "browser.download.open_pdf_attachments_inline" = true;
          "browser.download.useDownloadDir" = false;
          "browser.download.panel.shown" = true;
          "browser.laterrun.enabled" = false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.urlbar.shortcuts.bookmarks" = false;
          "browser.urlbar.shortcuts.history" = false;
          "browser.urlbar.shortcuts.tabs" = false;
          "browser.urlbar.suggest.engines" = false;
          "browser.urlbar.suggest.quicksuggest.sponsored" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnable" = false;
          "datareporting.policy.dataSubmissionPolicyAcceptedVersion" = 2;
          "extensions.pocket.enabled" = false;
          "privacy.globalprivacycontrol.enabled" = true;
          "privacy.globalprivacycontrol.functionality.enabled" = true;
          "privacy.globalprivacycontrol.was_ever_enabled" = true;
          "services.sync.username" = "krishnans2006@gmail.com";
          #"services.sync.syncInterval" = 600000;
          #"services.sync.syncThreshold" = 300;
          "svg.context-properties.content.enabled" = true;
          "widget.use-xdg-desktop-portal.file-picker" = 1;
        };
      };
    };
  };
}
