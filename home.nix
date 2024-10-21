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

    nodejs
    npm-check-updates
    sass

    dig

    git-subrepo

    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    lm_sensors # for `sensors` command

    vesktop

    element-desktop

    jetbrains.pycharm-professional
    jetbrains.webstorm
    jetbrains.idea-ultimate
    jetbrains.clion

    platformio

    kicad
    gimp

    qmk

    # temp
    (vivaldi.overrideAttrs (oldAttrs: {
      dontWrapQtApps = false;
      dontPatchELF = true;
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.kdePackages.wrapQtAppsHook ];
    }))
    google-chrome
  ];

  # plasma-manager (KDE Plasma 6 Configuration)
  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Mountain/contents/images_dark/5120x2880.png";
    };

    configFile = {
      "kdeglobals"."General"."AccentColor" = "0,211,184";
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
                "applications:kdesystemsettings.desktop"
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
