{ import-tree, root, ... }:

{
  imports = [
    # Custom modules
    (import-tree (root + "/modules/home"))
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
    enableGithubCLI = true;
    enableGithubCLIAutoLogin = true;
  };
  modules.ssh.enable = true;
  modules.tailscale.enable = true;
  modules.fs-mounts = {
    janux = true;
    ews = true;
  };

  modules.fonts.enable = true;

  modules.utils.enable = true;
  modules.vesktop = {
    enable = true;
    autostart = true;
  };
  modules.slack = {
    enable = true;
    autostart = true;
  };
  modules.element = {
    enable = true;
    autostart = true;
  };
  modules.mattermost = {
    enable = true;
    autostart = true;
    servers = [
      {
        name = "TJ CSL";
        url = "https://mattermost.tjhsst.edu/";
      }
      {
        name = "Matterless";
        url = "https://matterless.tjhsst.edu/";
      }
    ];
  };
  modules.zulip = {
    enable = true;
    autostart = true;
  };
  modules.zen-browser = {
    enable = true;
    autostart = true;
  };
  modules.bitwarden-desktop = {
    enable = true;
    autostart = true;
  };
  modules.libreoffice.enable = true;
  modules.jetbrains.enableAll = false;
  modules.zed-editor.enable = true;
  modules.fastx-client.enable = true;
  modules.jellybox.enable = true;
}
