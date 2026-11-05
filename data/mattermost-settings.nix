{ home, autostart }:

{
  version = 4;
  showTrayIcon = true;
  trayIconTheme = "light";
  minimizeToTray = true;
  notifications = {
    flashWindow = 2;
    bounceIcon = true;
    bounceIconType = "informational";
  };
  showUnreadBadge = true;
  useSpellChecker = true;
  enableHardwareAcceleration = true;
  autostart = autostart;
  hideOnStart = autostart;
  spellCheckerLocales = [ ];
  darkMode = true;
  lastActiveServer = 0;
  downloadLocation = "${home}/Downloads/Mattermost";
  startInFullscreen = false;
  logLevel = "info";
  enableMetrics = false;
  viewLimit = 15;
  themeSyncing = true;
  autoCheckForUpdates = true;
  alwaysMinimize = true;
  enableSentry = true;
  skippedVersions = [ ];
  useNativeTitleBar = false;
}
