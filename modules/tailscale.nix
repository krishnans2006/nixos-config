{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tailscale;
in
{
  options.modules.tailscale = {
    enable = mkEnableOption "Enable Tailscale";
    enableTaildrive = mkEnableOption "Enable Tailscale Taildrive";
    taildrivePath = mkOption {
      type = types.str;
      default = "home/krishnan/Filesystems/Tailscale";
      description = "Path to mount Taildrive";
    };
  };

  config = mkIf cfg.enable {
    services.tailscale.enable = true;

    services.davfs2 = mkIf cfg.enableTaildrive {
      enable = true;
      davGroup = "davfs2";
    };
    users.users."krishnan".extraGroups = mkIf cfg.enableTaildrive [ "davfs2" ];

    fileSystems."${cfg.taildrivePath}" = mkIf cfg.enableTaildrive {
      device = "http://100.100.100.100:8080";
      mountPoint = "${cfg.taildrivePath}";
      depends = [ "/" ];
      noCheck = true;
      fsType = "davfs";
      options = [ "_netdev" "rw" "file_mode=0664" "dir_mode=2775" "user" "uid=${toString config.users.users."krishnan".uid}" "grpid" ];
    };
    environment.etc."davfs2/secrets" = mkIf cfg.enableTaildrive {
      enable = true;
      text = "http://100.100.100.100:8080 \"\" \"\"";
      mode = "0600";
    };
  };
}
