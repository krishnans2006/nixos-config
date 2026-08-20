{ import-tree, root, ... }:

{
  imports = [
    (import-tree "${root}/modules/home")
    #
  ];

  programs.home-manager.enable = true;

  home = {
    username = "ks128";
    homeDirectory = "/home/ks128";
    stateVersion = "25.05";
  };

  # Non-NixOS
  targets.genericLinux = {
    enable = true;
    gpu.enable = false;
  };

  modules.impermanence.enable = false;
  modules.secrets.enable = false;
  modules.nix-user-chroot.enable = true;

  modules.plasma.enable = false;
  modules.tailscale.enable = false;
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
  modules.ssh = {
    enable = true;
    enableAuthorizedKeys = true;
  };
  modules.fs-mounts = {
    tjcsl = false;
    ews = false;
  };
  modules.gaming = {
    enableLutris = false;
    enableMinecraft = false;
  };

  modules.packages = {
    utils.enable = false;
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
