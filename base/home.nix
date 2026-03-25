{ config, pkgs, ... }:

{
  imports = [
    ../config/home/basic.nix
    ../config/home/secrets.nix
  ];

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    pkg-config

    sops
    age
    ssh-to-age

    micro

    zsh-powerlevel10k
    meslo-lgs-nf

    kdePackages.kate
    kdePackages.bluedevil
    kdePackages.filelight
    # kdePackages.kdenlive
    # krita

    libreoffice-qt
    hunspell
    hunspellDicts.en_US

    nodejs
    pnpm
    npm-check-updates
    sass

    vesktop
    discord-canary
    #libunity  # required for vesktop
    slack
    element-desktop
    signal-desktop
    mattermost-desktop
    zulip

    zoom-us

    # jetbrains.pycharm
    # jetbrains.webstorm
    # jetbrains.idea
    # jetbrains.clion
    # jetbrains.goland
    # jetbrains.rust-rover

    (python314.withPackages (ps: with ps; [
      jupyterlab
      jupyterlab-lsp
      jedi-language-server
      tqdm
      matplotlib
      numpy
      scipy
      pandas
      discordpy
    ]))
    poetry
    pipenv
    octodns

    ansible
    sshpass

    sshfs

    jdk

    platformio

    nixfmt
    nixd

    # kicad
    # gimp

    qmk
    via
    #vial

    quickemu
    #quickgui

    audacity
    vlc
    obs-studio

    lc3tools

    lutris-free
    prismlauncher  # minecraft
    #sauerbraten
  ];

  # Nanorc
  home.file.".nanorc".text = ''
    set autoindent
    set tabsize 4
    set tabstospaces
    set linenumbers
  '';

  # GDB (for ECE 391)
  home.file.".config/gdb/gdbinit" = {
    text = "set auto-load safe-path /";
  };

  programs.zoxide = {
    enable = true;
    options = [ "--cmd" "cd" ];
  };

  # direnv for auto-activation of .envrc (and devenv)
  programs.direnv = {
    enable = true;
    #enableBashIntegration = true;
    nix-direnv.enable = true;
    config = {
      global."warn_timeout" = 0;
    };
  };

  # Flatpaks
  services.flatpak = {
    remotes = [
      { name = "flathub"; location = "https://dl.flathub.org/repo/flathub.flatpakrepo"; }
    ];
    packages = [
      "app.zen_browser.zen"
      "com.bitwarden.desktop"
    ];
    update.onActivation = true;
  };
  
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

  programs.vscode.enable = true;
}
