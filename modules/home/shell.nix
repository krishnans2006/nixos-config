{ config, lib, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.shell;

  atuinSettings = import (root + "/data/atuin-settings.nix") { inherit config; };
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
    enableZoxide = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Zoxide to replace the cd command";
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
          plugins = [ "git" "git-auto-fetch" "poetry" "sudo" ];
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
        source = root + "/dotfiles";
        recursive = true;  # link recursively
        executable = true;  # make all files executable
      };

      programs.zsh.initContent = ''
        source ~/.dotfiles/aliases-nix.zsh
      '';
    })

    # Theme
    (mkIf cfg.enableTheme {
      home.packages = [ pkgs.meslo-lgs-nf ];

      programs.zsh = {
        oh-my-zsh.theme = "";  # powerlevel10k

        localVariables.POWERLEVEL9K_CONFIG_FILE = "~/.dotfiles/.p10k.zsh";

        initContent = ''
          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
          [[ ! -f ~/.dotfiles/.p10k.zsh ]] || source ~/.dotfiles/.p10k.zsh
        '';
      };
    })

    # Atuin
    (mkIf cfg.enableAtuin {
      modules.secrets.enable = mkForce true;

      # Pull in secrets
      sops.secrets = {
        "atuin/key" = { };  # Unused
        "atuin/key_b64" = { };
      };

      programs.atuin = {
        enable = true;
        forceOverwriteSettings = true;
        settings = atuinSettings;

        #daemon.enable = true;
      };

      # Impermanence
      modules.impermanence.persistDirs = [ ".local/share/atuin" ];
    })

    # Zoxide
    (mkIf cfg.enableZoxide {
      programs.zoxide = {
        enable = true;
        options = [ "--cmd" "cd" ];
      };

      # Impermanence
      modules.impermanence.persistDirs = [ ".local/share/zoxide" ];  # db.zo
    })
  ]);
}
