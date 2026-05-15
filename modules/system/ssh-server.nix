{ config, lib, ... }:

with lib;

let
  cfg = config.modules.ssh-server;
in
{
  options.modules.ssh-server = {
    enable = mkEnableOption "Enable OpenSSH server";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;

      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ "krishnan" ];
      };
    };
  };
}
