{ inputs, root, lib, ... }:

with inputs;

{
  imports = [
    # Base configuration
    "${root}/base/home.nix"

    # Custom modules
    (import-tree "${root}/modules/home")
  ];

  modules.impermanence.enable = false;
  modules.secrets.enable = lib.mkForce false;

  modules.plasma.enable = false;
  modules.tailscale.enable = true;
  modules.shell = {
    enable = true;
    enableDotfiles = true;
    enableTheme = true;
    enableAtuin = false;
    enableZoxide = true;
  };
  modules.direnv.enable = true;
  modules.git = {
    enable = true;
    enablePdfDiff = false;
  };
  modules.ssh.enable = true;
  modules.fs-mounts = {
    tjcsl = false;
    ews = false;
  };
  modules.gaming = {
    enableLutris = false;
    enableMinecraft = false;
  };

  modules.packages = {
    utils.enable = true;
    vesktop.enable = false;
    vesktop.autostart = false;
    slack.enable = false;
    slack.autostart = false;
    element.enable = false;
    element.autostart = false;
    mattermost.enable = false;
    mattermost.autostart = false;
    zulip.enable = false;
    zulip.autostart = false;
    zen-browser.enable = false;
    zen-browser.autostart = false;
    bitwarden-desktop.enable = false;
    bitwarden-desktop.autostart = false;
    firefox.enable = false;
    thunderbird.enable = false;
    libreoffice.enable = false;
    jetbrains.enableAll = false;
    zed-editor.enable = false;
  };
}
