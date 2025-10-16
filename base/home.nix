{ config, pkgs, osConfig, ... }:

let
  # For Kdenlive and CLion
  nixpkgs_old = import (builtins.fetchTree {
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "5785b6bb5eaae44e627d541023034e1601455827";
  }) { inherit (pkgs) system; config.allowUnfree = true; };
in {
  imports = [
    ../config/basic-home.nix
    ../config/secrets-home.nix
  ];

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    neofetch
    fastfetch

    zip
    xz
    unzip
    p7zip

    file
    which
    tree
    gnused
    gnutar
    htop
    ncdu

    pkg-config

    ffmpeg

    wl-clipboard

    sops
    age
    ssh-to-age

    micro

    zsh-powerlevel10k
    meslo-lgs-nf

    jq

    undollar
    pay-respects
    moreutils

    kdePackages.kate
    kdePackages.bluedevil
    kdePackages.filelight
    nixpkgs_old.kdePackages.kdenlive
    krita

    libreoffice-qt
    hunspell
    hunspellDicts.en_US

    nodejs
    npm-check-updates
    sass

    wireguard-tools

    dig
    nmap

    libxml2

    gh
    git-lfs
    git-subrepo
    git-filter-repo
    meld
    kdiff3

    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    lm_sensors # for `sensors` command
    memtester

    rclone

    vesktop
    discord-canary
    #libunity  # required for vesktop
    slack
    element-desktop
    signal-desktop
    mattermost-desktop

    zoom-us

    devenv

    jetbrains.pycharm-professional
    jetbrains.webstorm
    jetbrains.idea-ultimate
    nixpkgs_old.jetbrains.clion
    jetbrains.goland
    jetbrains.rust-rover

    (python312.withPackages (ps: with ps; [
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

    nodejs_22
    pnpm

    platformio

    nixfmt-rfc-style

    kicad
    gimp

    qmk
    via
    #vial

    quickemu
    #quickgui

    audacity
    vlc
    obs-studio

    lc3tools

    mission-planner

    lutris-free
    prismlauncher  # minecraft
    #sauerbraten
    superTuxKart

    # temp
    (vivaldi.overrideAttrs (oldAttrs: {
      dontWrapQtApps = false;
      dontPatchELF = true;
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.kdePackages.wrapQtAppsHook ];
    }))
    google-chrome
    spotify
    #duplicity
    #deja-dup
  ];

  # KDE Connect
  #services.kdeconnect.enable = true;

  programs.konsole = {
    enable = true;
    defaultProfile = "Krishnan";

    profiles = {
      Krishnan = {
        name = "Krishnan";
        command = "/run/current-system/sw/bin/zsh";
        font = {
          name = "Hack";
          size = 10;
        };

        extraConfig = {
          General.Parent = "FALLBACK/";
          Scrolling.HistoryMode = "2";
        };
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      append = true;
      extended = true;
      ignoreSpace = true;
      save = 1000000000;
      share = true;
      size = 1000000000;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "git-auto-fetch" "poetry" "sudo" ];
      theme = "";  # powerlevel10k
    };

    localVariables = {
      POWERLEVEL9K_CONFIG_FILE = "~/.dotfiles/.p10k.zsh";
    };

    initContent = ''
      autoload zmv

      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      [[ ! -f ~/.dotfiles/.p10k.zsh ]] || source ~/.dotfiles/.p10k.zsh

      source ~/.dotfiles/aliases-nix.zsh
    '';
  };

  # link all files in `./dotfiles` to `~/.dotfiles`
  home.file.".dotfiles" = {
    source = ../dotfiles;
    recursive = true;   # link recursively
    executable = true;  # make all files executable
  };

  # GDB (for ECE 391)
  home.file.".config/gdb/gdbinit" = {
    text = "set auto-load safe-path /";
  };

  programs.atuin = {
    enable = true;

    enableBashIntegration = false;
    enableFishIntegration = false;
    enableNushellIntegration = false;
    enableZshIntegration = true;

    #daemon.enable = true;

    # https://docs.atuin.sh/configuration/config/
    settings = {
      db_path = "~/.local/share/atuin/history.db";
      key_path = config.sops.secrets."atuin/key_b64".path;
      session_path = "~/.local/share/atuin/session";
      dialect = "us";

      auto_sync = true;
      update_check = false;
      sync_address = "https://api.atuin.sh";
      sync_frequency = "5m";

      search_mode = "fuzzy";
      filter_mode = "global";
      workspaces = false;  # Filter mode for when in a git repository

      style = "auto";  # Full when possible
      invert = false;
      inline_height = 0;
      show_preview = true;
      max_preview_height = 4;
      show_help = true;
      show_tabs = false;
      exit_mode = "return-original";

      store_failed = true;
      secrets_filter = true;

      network_timeout = 30;
      network_connect_timeout = 5;
      local_timeout = 5;

      enter_accept = true;
      sync.records = true;
    };
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

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Krishnan Shankar";
    userEmail = "krishnans2006@gmail.com";
    signing = {
      key = "A30C1843F47048435D543D6829CB06A840D0E14A";
      signByDefault = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      core.autocrlf = "input";
      pull.rebase = false;
    };
    ignores = [
      ".idea/"
      ".vscode/"
      ".direnv/"
      ".envrc"
    ];
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        controlMaster = "auto";
        controlPath = "~/.ssh/master-%r@%h:%p";
        controlPersist = "3s";
      };
      "ews" = {
        hostname = "linux.ews.illinois.edu";
        identityFile = "~/.ssh/id_ed25519";
        user = "ks128";
        forwardX11 = true;
        forwardX11Trusted = true;
        extraOptions = {
          RequestTTY = "yes";
          RemoteCommand = "/bin/zsh";
        };
      };
      "ews-391" = {
        hostname = "eceb-3026.ews.illinois.edu";
        identityFile = "~/.ssh/id_ed25519";
        user = "ks128";
        forwardX11 = true;
        forwardX11Trusted = true;
        extraOptions = {
          RequestTTY = "yes";
          RemoteCommand = "/bin/zsh";
        };
      };
      "oracle-amp" = {
        hostname = "150.136.13.65";
        identityFile = "~/.ssh/id_ed25519";
        user = "ubuntu";
      };
      "oracle-vm1" = {
        hostname = "150.136.122.56";
        identityFile = "~/.ssh/id_ed25519";
        user = "ubuntu";
      };
      "oracle-vm2" = {
        hostname = "129.153.27.23";
        identityFile = "~/.ssh/id_ed25519";
        user = "ubuntu";
      };
      "piserver.local" = {
        hostname = "piserver.local";
        user = "krishnan";
      };
      "tjfridge" = {
        hostname = "fridge.tjhsst.edu";  # 198.38.23.53
        user = "kshankar";
      };
      "tjras" = {
        hostname = "ras2.tjhsst.edu";  # 198.38.18.201
        user = "2024kshankar";
      };
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
