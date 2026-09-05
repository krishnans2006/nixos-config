{ import-tree, root, ... }:

{
  imports = [
    # Custom modules
    (import-tree "${root}/modules/home")
  ];

  modules.secrets.enable = true;

  modules.plasma.enable = true;

  modules.shell = {
    enable = true;
    enableDotfiles = true;
    enableTheme = true;
    enableAtuin = true;
    enableZoxide = true;
  };
  modules.direnv.enable = true;
  modules.git = {
    enable = true;
    enablePdfDiff = true;
  };
  modules.ssh.enable = true;
  modules.tailscale.enable = true;
  modules.fs-mounts = {
    tjcsl = true;
    # ews = true;
  };

  modules.fonts.enable = true;

  modules.packages = {
    utils.enable = true;
    vesktop.enable = true;
    vesktop.autostart = true;
    slack.enable = true;
    slack.autostart = true;
    element.enable = true;
    element.autostart = true;
    mattermost.enable = true;
    mattermost.autostart = true;
    mattermost.servers = [
      {
        name = "TJ CSL";
        url = "https://mattermost.tjhsst.edu/";
      }
      {
        name = "Matterless";
        url = "https://matterless.tjhsst.edu/";
      }
    ];
    zulip.enable = true;
    zulip.autostart = true;
    zen-browser.enable = true;
    zen-browser.autostart = true;
    bitwarden-desktop.enable = true;
    bitwarden-desktop.autostart = true;
    libreoffice.enable = true;
    jetbrains.enableAll = false;
    zed-editor.enable = true;
  };
}
