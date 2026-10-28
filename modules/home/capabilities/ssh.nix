{ config, lib, osConfig ? null, root, ... }:

with lib;

let
  cfg = config.modules.ssh;

  data = import (root + "/data/ssh.nix");
  inherit (data) sshConfig;
in
{
  options.modules.ssh = {
    enable = mkEnableOption "Enable custom SSH client configuration and known hosts";
    enableAuthorizedKeys = mkEnableOption "Install authorized SSH keys on non-NixOS systems";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = sshConfig;
      };
    }

    (mkIf cfg.enableAuthorizedKeys (
      let
        verify-system = import (root + "/utils/verify-system.nix") {
          inherit lib osConfig;
          option = "modules.ssh-server.enable";
          type = "forbidden";
          reason = "conflicts with modules.ssh.enableAuthorizedKeys";
        };
      in
      verify-system.apply {
        # SELinux-confined sshd cannot follow a Nix store symlink
        home.activation.installAuthorizedKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          install -d -m 0700 ${escapeShellArg "${config.home.homeDirectory}/.ssh"}
          rm -f ${escapeShellArg "${config.home.homeDirectory}/.ssh/authorized_keys"}
          install -m 0600 ${
            root + "/dotfiles/authorized_keys"
          } ${escapeShellArg "${config.home.homeDirectory}/.ssh/authorized_keys"}
        '';
      }
    ))
  ]);
}
