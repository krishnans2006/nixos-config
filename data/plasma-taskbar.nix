{ lib, hasBattery }:

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
        #
      };
    }

    # Pager
    {
      pager = { };  # default config; customize later if needed
    }

    # Icons-Only Task Manager
    {
      iconTasks = {
        launchers = [
          "applications:org.kde.dolphin.desktop"
          "applications:org.kde.konsole.desktop"
          "applications:zen-beta.desktop"
          "applications:vesktop.desktop"
          "applications:code.desktop"
          "applications:dev.zed.Zed.desktop"
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
          shown = [
            "org.kde.plasma.bluetooth"
          ] ++ lib.optional hasBattery "org.kde.plasma.battery";
          hidden = [ "org.kde.plasma.addons.katesessions" ];
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
        timeZone.format = "code";
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
