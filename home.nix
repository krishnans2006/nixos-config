{ config, pkgs, ... }:

{
  home.username = "krishnan";
  home.homeDirectory = "/home/krishnan";

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # set cursor size and dpi for 4k monitor
  # xresources.properties = {
  #   "Xcursor.size" = 16;
  #   "Xft.dpi" = 172;
  # };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    neofetch

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

    micro

    kdePackages.kate
    kdePackages.bluedevil
    kdePackages.filelight
    #kdePackages.partitionmanager
    kdePackages.kdenlive

    libreoffice-qt
    hunspell
    hunspellDicts.en_US

    nodejs
    npm-check-updates
    sass

    dig

    git-subrepo

    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    lm_sensors # for `sensors` command
    memtester

    rclone

    vesktop
    #libunity  # required for vesktop
    slack
    element-desktop

    devenv

    jetbrains.pycharm-professional
    jetbrains.webstorm
    jetbrains.idea-ultimate
    jetbrains.clion

    python312
    poetry
    octodns

    platformio

    kicad
    gimp

    qmk

    quickemu
    #quickgui

    audacity
    vlc

    lc3tools

    # temp
    (vivaldi.overrideAttrs (oldAttrs: {
      dontWrapQtApps = false;
      dontPatchELF = true;
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.kdePackages.wrapQtAppsHook ];
    }))
    google-chrome
    spotify
    duplicity
    deja-dup
  ];

  # KDE Connect
  #services.kdeconnect.enable = true;

  # plasma-manager (KDE Plasma 6 Configuration)
  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Mountain/contents/images_dark/5120x2880.png";
    };

    configFile = {
      kdeglobals.General.AccentColor = "0,211,184";
      spectaclerc.General = {
        autoSaveImage = true;  # After taking a screenshot: Save file to default folder
        clipboardGroup = "PostScreenshotCopyImage";  # After taking a screenshot: Copy image to clipboard
        launchAction = "DoNotTakeScreenshot";  # When launching Spectacle: Do not take a screenshot automatically
        rememberSelectionRect = "Always";  # Remember selected area: Always (Hint: Use right-click to clear selection)
      };
      kwinrc = {
        Effect-overview.TouchBorderActivate = 4;
        Effect-shakecursor.Magnification = 10;
        ElectricBorders = {
          BottomLeft = "ApplicationLauncher";
        };
        TouchEdges = {
          Left = "ActivityManager";
          Top = "KRunner";
        };
      };
    };

    shortcuts = {
      plasmashell = {
        "stop current activity" = "";  # Free up Meta+S
      };
      kaccess = {
        "Toggle Screen Reader On and Off" = "";  # Free up Meta+Alt+S
      };
    };

    spectacle.shortcuts = {
      captureActiveWindow = [ "Meta+S" "Meta+Print" ];                       # Meta+Print
      captureCurrentMonitor = [ "Meta+Alt+S" "Meta+Alt+Print" ];             # <None>
      captureEntireDesktop = [ "Meta+Alt+Shift+S" "Meta+Alt+Shift+Print" ];  # Shift+Print
      captureRectangularRegion = [ "Meta+Shift+S" "Meta+Shift+Print" ];      # Meta+Shift+Print
      captureWindowUnderCursor = [];                                         # Meta+Ctrl+Print
      launch = [];                                                           # Print, Meta+Shift+S
      launchWithoutCapturing = [];                                           # <None>
      recordRegion = [ "Meta+Shift+R" ];                                     # Meta+Shift+R, Meta+R
      recordScreen = [ "Meta+Alt+R" ];                                       # Meta+Alt+R
      recordWindow = [ "Meta+R" ];                                           # Meta+Ctrl+R
    };

    kscreenlocker = {
      appearance = {
        alwaysShowClock = true;
        showMediaControls = true;  # Show under unlocking prompt
        #wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Mountain/contents/images_dark/5120x2880.png";
        wallpaperSlideShow = {
          path = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/";
          interval = 300;  # 5 minutes
        };
      };

      # Automatic
      autoLock = false;
      timeout = 0;

      # Sleep/Lock
      lockOnResume = true;
      passwordRequired = true;
      passwordRequiredDelay = 0;

      # Startup
      lockOnStartup = true;
    };

    kwin = {
      borderlessMaximizedWindows = true;
      cornerBarrier = true;
      edgeBarrier = 100;
      #effects = {}
      #nightLight = {}
      #scripts.polonium = {}
      #tiling = {}
      #titlebarButtons = {}
      #virtualDesktops = {}
    };

    powerdevil = {
      AC = {
        # Suspend Session
        autoSuspend = {
          action = "nothing";  # When inactive: Do nothing
          idleTimeout = null;
        };
        powerButtonAction = "showLogoutScreen";  # When power button pressed: Show logout screen
        whenLaptopLidClosed = "sleep";  # When laptop lid closed: Sleep
        inhibitLidActionWhenExternalMonitorConnected = true;  # Even when an external monitor is connected: Unchecked
        whenSleepingEnter = "standby";  # When sleeping, enter: Standby

        # Display and Brightness
        displayBrightness = null;  # Change screen brightness: Unchecked
        dimDisplay = {
          enable = false;  # Dim automatically: Never
          idleTimeout = null;
        };
        turnOffDisplay = {
          idleTimeout = "never";  # Turn off screen: Never
          #idleTimeoutWhenLocked = 60;  # ...When locked: 1 minute
          # The above is commented due to the below error:
          # Setting programs.plasma.powerdevil.AC.turnOffDisplay.idleTimeoutWhenLocked for idleTimeout "never" is not supported.
        };
      };

      battery = {
        # Suspend Session
        autoSuspend = {
          action = "sleep";  # When inactive: Sleep
          idleTimeout = 600;  # ...After 10 minutes
        };
        powerButtonAction = "showLogoutScreen";  # When power button pressed: Show logout screen
        whenLaptopLidClosed = "sleep";  # When laptop lid closed: Sleep
        inhibitLidActionWhenExternalMonitorConnected = true;  # Even when an external monitor is connected: Unchecked
        whenSleepingEnter = "standby";  # When sleeping, enter: Standby

        # Display and Brightness
        displayBrightness = null;  # Change screen brightness: Unchecked
        dimDisplay = {
          enable = true;  # Dim automatically:
          idleTimeout = 120;  # ...2 minutes
        };
        turnOffDisplay = {
          idleTimeout = 300;  # Turn off screen: 5 minutes
          idleTimeoutWhenLocked = 60;  # ...When locked: 1 minute
        };
      };

      lowBattery = {
        # Suspend Session
        autoSuspend = {
          action = "sleep";  # When inactive: Sleep
          idleTimeout = 300;  # ...After 5 minutes
        };
        powerButtonAction = "showLogoutScreen";  # When power button pressed: Show logout screen
        whenLaptopLidClosed = "sleep";  # When laptop lid closed: Sleep
        inhibitLidActionWhenExternalMonitorConnected = true;  # Even when an external monitor is connected: Unchecked
        whenSleepingEnter = "standby";  # When sleeping, enter: Standby

        # Display and Brightness
        displayBrightness = 30;  # Change screen brightness: 30%
        dimDisplay = {
          enable = true;  # Dim automatically:
          idleTimeout = 60;  # ...1 minute
        };
        turnOffDisplay = {
          idleTimeout = 120;  # Turn off screen: 2 minutes
          idleTimeoutWhenLocked = 60;  # ...When locked: 1 minute
        };
      };

      # Advanced Power Settings
      batteryLevels = {
        lowLevel = 15;  # Low level: 15%
        criticalLevel = 5;  # Critical level: 5%
        criticalAction = "hibernate";
      };
      general.pausePlayersOnSuspend = true;  # Media playback:: Pause media players when suspending
    };

    panels = [
      {
        location = "bottom";
        alignment = "center";
        lengthMode = "fill";  # fill width
        hiding = "normalpanel";  # always visible
        floating = true;
        height = 44;
        screen = "all";

        widgets = [
          # Application Launcher
          {
            kickoff = {
              icon = "nix-snowflake-white";
            };
          }

          # Pager
          {
            pager = {};  # default config; customize later if needed
          }

          # Icons-Only Task Manager
          {
            iconTasks = {
              launchers = [
                "applications:org.kde.dolphin.desktop"
                "applications:org.kde.konsole.desktop"
                "applications:firefox.desktop"
                "applications:systemsettings.desktop"
              ];
              appearance = {
                showTooltips = true;  # Show small window previews when hovering over tasks
                highlightWindows = true;  # Hide other windows when hovering over previews
                indicateAudioStreams = true;  # Mark applications that play audio
                fill = true;  # Fill free space on panel
                rows.multirowView = "never";
                iconSpacing = "medium";  # Normal
              };
              behavior = {
                grouping = {
                  method = "byProgramName";  # Group: By program name
                  clickAction = "cycle";  # Clicking grouped task: Cycles through tasks
                };
                sortingMethod = "manually";  # Sort: Manually
                minimizeActiveTaskOnClick = true;  # Clicking active task: Minimizes the task
                middleClickAction = "newInstance";  # Middle-clicking any task: Opens a new window
                wheel = {
                  switchBetweenTasks = true;  # Mouse wheel: Cycles through tasks
                  ignoreMinimizedTasks = true;  # Skip minimized tasks
                };
                showTasks = {
                  onlyInCurrentScreen = false;
                  onlyInCurrentDesktop = true;
                  onlyInCurrentActivity = true;
                  onlyMinimized = false;
                };
                unhideOnAttentionNeeded = true;  # When panel is hidden: Unhide when a window wants attention
                newTasksAppearOn = "right";  # New tasks appear: To the right
              };
            };
          }

          # Margins Separator
          "org.kde.plasma.marginsseparator"

          # System Tray
          {
            systemTray = {
              icons = {
                spacing = "medium";  # Panel icon spacing: Normal
                scaleToFit = false;  # Panel icon size: Small
              };
              items = {
                showAll = false;
                hidden = [
                  "org.kde.plasma.addons.katesessions"
                  #"org.kde.plasma.diskquota"
                  #"org.kde.plasma.weatherreport"
                ];
              };
            };
          }

          # Digital Clock
          {
            digitalClock = {
              date = {
                enable = true;
                format = "shortDate";
                position = "adaptive";
              };
              time = {
                showSeconds = "always";
                format = "12h";
              };
              timeZone = {
                format = "code";
              };
              calendar = {
                firstDayOfWeek = "sunday";
                #plugins = [];
                showWeekNumbers = false;
              };
            };
          }

          # Peek At Desktop
          "org.kde.plasma.showdesktop"
        ];
      }
    ];
  };

  # direnv for auto-activation of .envrc (and devenv)
  programs.direnv = {
    enable = true;
    #enableBashIntegration = true;
    nix-direnv.enable = true;
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
    };
  };

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";

    controlMaster = "auto";
    controlPath = "~/.ssh/master-%r@%h:%p";
    controlPersist = "3s";

    matchBlocks = {
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
        "browser.ml.chat.enabled" = true;
        "browser.ml.chat.provider" = "https://gemini.google.com";
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.urlbar.shortcuts.bookmarks" = false;
        "browser.urlbar.shortcuts.history" = false;
        "browser.urlbar.shortcuts.tabs" = false;
        "browser.urlbar.suggest.engines" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "datareporting.policy.dataSubmissionEnable" = false;
        "datareporting.policy.dataSubmissionPolicyAcceptedVersion" = 2;
        "extensions.pocket.enabled" = false;
        "services.sync.username" = "krishnans2006@gmail.com";
        #"services.sync.syncInterval" = 600000;
        #"services.sync.syncThreshold" = 300;
        "svg.context-properties.content.enabled" = true;
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };
    };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      pkief.material-icon-theme

      #ms-vscode-remote.vscode-remote-extensionpack
      ms-vsliveshare.vsliveshare

      eamodio.gitlens
      github.vscode-pull-request-github

      #donjayamanne.python-extension-pack
      ms-toolsai.jupyter
      wakatime.vscode-wakatime
      redhat.vscode-yaml
      davidanson.vscode-markdownlint
    ];
  };

  # starship - an customizable prompt for any shell
  # programs.starship = {
  #   enable = true;
  #   # custom settings
  #   settings = {
  #     add_newline = false;
  #     aws.disabled = true;
  #     gcloud.disabled = true;
  #     line_break.disabled = true;
  #   };
  # };

  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  # programs.alacritty = {
  #   enable = true;
  #   # custom settings
  #   settings = {
  #     env.TERM = "xterm-256color";
  #     font = {
  #       size = 12;
  #       draw_bold_text_with_bright_colors = true;
  #     };
  #     scrolling.multiplier = 5;
  #     selection.save_to_clipboard = true;
  #   };
  # };

  # programs.bash = {
  #   enable = true;
  #   enableCompletion = true;
  #   # TODO add your custom bashrc here
  #   bashrcExtra = ''
  #     export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
  #   '';
  #
  #   # set some aliases, feel free to add more or remove some
  #   shellAliases = {
  #     k = "kubectl";
  #     urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
  #     urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
  #   };
  # };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
