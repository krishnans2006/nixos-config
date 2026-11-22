{ config, lib, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.krishnan-user;
in
{
  options.modules.krishnan-user = {
    enable = mkEnableOption "the primary local user account (with zsh)";
    username = mkOption {
      type = types.str;
      default = "krishnan";
      description = "Username of the primary local account";
    };
    enablePresetPassword = mkOption {
      type = types.bool;
      default = true;
      description = "Set the primary local user's password from secrets";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # Allow setting the password with passwd when no preset is available.
      users.mutableUsers = !cfg.enablePresetPassword;

      # Disable root login (sudo only)
      users.users."root".hashedPassword = null;

      users.groups.fuse = { };

      users.users.${cfg.username} = {
        uid = 1000;
        isNormalUser = true;
        description = "Krishnan Shankar";

        # networkmanager, wheel: initially set (in configuration.nix)
        # dialout: for serial/USB ports
        # fuse: for sshfs mounts
        extraGroups = [ "networkmanager" "wheel" "dialout" "fuse" ];
        packages = [ ];  # Managed by home-manager
        shell = pkgs.zsh;

        # See ssh-server.nix
        openssh.authorizedKeys.keyFiles = [ (root + "/dotfiles/authorized_keys") ];
      };
      security.sudo.wheelNeedsPassword = false;

      # Shell
      programs.zsh.enable = true;
      environment.pathsToLink = [ "/share/zsh" ];

      # Mounts (fuse)
      programs.fuse.userAllowOther = true;
    }

    (mkIf cfg.enablePresetPassword {
      modules.secrets.enable = mkForce true;

      # Hashed password from secrets
      sops.secrets."password".neededForUsers = true;
      users.users.${cfg.username}.hashedPasswordFile = config.sops.secrets."password".path;
    })
  ]);
}
