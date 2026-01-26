{ config, lib, pkgs, osConfig, ... }:

with lib;

let
  cfg = config.modules.plasma;
  osCfg = osConfig.modules.plasma;
in {
  options.modules.plasma = {
    enable = mkEnableOption "Enable a customized KDE Plasma 6 DE";
  };

  # Must be enabled in system config
  config = mkIf cfg.enable ( mkAssert osCfg.enable "modules.plasma is not enabled in system config" {
    programs.plasma = {
      enable = true;
      overrideConfig = true;  # WARNING: Beware! This resets all configuration to default

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
        ksmserverrc.General.loginMode = "emptySession";
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
        klipperrc = {
          General = {
            IgnoreImages = false;
            MaxClipItems = 2048;
          };
        };
        ksplashrc = {
          KSplash = {
            Engine = "none";
            Theme = "None";
          };
        };
        dolphinrc = {
          General = {
            ShowStatusBar = "FullWidth";  # Make bottom status bar full width (show remaining disk space)
          };
          DetailsMode = {
            # IconSize is not necessary, since PreviewsShown = true in dataFile below
            PreviewSize = 16;
          };
        };
      };

      dataFile = {
        "dolphin/view_properties/global/.directory" = {
          Settings.HiddenFilesShown = true;
          Dolphin = {
            ViewMode = 1;  # View Style: Details
            PreviewsShown = true;
            GroupedSorting = false;
            SortRole = "text";
            SortOrder = 0;  # Qt::AscendingOrder (maybe)
            SortFoldersFirst = true;
            SortHiddenLast = true;
            DynamicViewPassed = false;
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
        borderlessMaximizedWindows = false;
        cornerBarrier = true;
        edgeBarrier = 100;
        #effects = {}
        nightLight = {
          enable = true;
          mode = "times";
          time.evening = "19:30";
          time.morning = "06:30";
          transitionTime = 60;
          temperature.day = 6500;
          temperature.night = 4000;
        };
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
                  "applications:app.zen_browser.zen.desktop"
                  "applications:vesktop.desktop"
                  "applications:code.desktop"
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

      input.keyboard = {
        layouts = [
          {
            displayName = "-";
            layout = "us";
          }
          {
            displayName = "^";
            layout = "us";
            variant = "colemak_dh";
          }
        ];
        options = [
          "compose:menu"
          "caps:none"
        ];
      };
    };

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
  });
}
