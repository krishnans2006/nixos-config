{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.shell;
in
{
  options.modules.shell = {
    enable = mkEnableOption "Enable custom shell configuration";
    enableDotfiles = mkOption {
      type = types.bool;
      default = true;
      description = "Enable linking of custom dotfiles from ./dotfiles";
    };
    enableTheme = mkOption {
      type = types.bool;
      default = true;
      description = "Enable custom shell theme (powerlevel10k)";
    };
    enableAtuin = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Atuin shell history manager";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Option setting assertions
    {
      assertions = [
        {
          # enableTheme can only be enabled if enableDotfiles is also enabled
          assertion = !(cfg.enableTheme && !cfg.enableDotfiles);
          message = "enableTheme can only be enabled if enableDotfiles is also enabled";
        }
      ];
    }

    # Base shell config
    {
      home.shell = {
        # Only enable shell integration for zsh
        # By default it's enabled for all shells but this is unnecessary
        enableShellIntegration = false;
        enableZshIntegration = true;
      };

      programs.zsh = {
        enable = true;

        # ~/.config/zsh instead of ~/.zsh
        dotDir = "${config.xdg.configHome}/zsh";

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
          plugins = [
            "git"
            "git-auto-fetch"
            "poetry"
            "sudo"
          ];
        };

        initContent = ''
          autoload zmv
        '';
      };
    }

    # Dotfiles
    (mkIf cfg.enableDotfiles {
      # link all files in `./dotfiles` to `~/.dotfiles`
      home.file.".dotfiles" = {
        source = ../../dotfiles;
        recursive = true; # link recursively
        executable = true; # make all files executable
      };

      programs.zsh.initContent = ''
        source ~/.dotfiles/aliases-nix.zsh
      '';
    })

    # Theme
    (mkIf cfg.enableTheme {
      programs.zsh = {
        oh-my-zsh.theme = ""; # powerlevel10k

        localVariables.POWERLEVEL9K_CONFIG_FILE = "~/.dotfiles/.p10k.zsh";

        initContent = ''
          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
          [[ ! -f ~/.dotfiles/.p10k.zsh ]] || source ~/.dotfiles/.p10k.zsh
        '';
      };
    })

    # Atuin
    (mkIf cfg.enableAtuin {
      programs.atuin = {
        enable = true;
        forceOverwriteSettings = true;

        #daemon.enable = true;

        # https://docs.atuin.sh/configuration/config/
        settings = {
          db_path = "~/.local/share/atuin/history.db";
          key_path = config.sops.secrets."atuin/key_b64".path;
          session_path = "~/.local/share/atuin/session";
          dialect = "us";

          auto_sync = true;
          update_check = false;
          sync_address = "https://atuin.krishy.dev";
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
    })
  ]);
}
