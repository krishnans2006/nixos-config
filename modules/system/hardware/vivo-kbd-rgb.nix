{ config, lib, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.vivo-kbd-rgb;

  vrgb = pkgs.callPackage "${root}/custom/vrgb.nix" { };
in
{
  options.modules.vivo-kbd-rgb = {
    enable = mkEnableOption "ASUS Vivobook keyboard RGB via vrgb (HID LampArray / ITE5570)";

    mode = mkOption {
      type = types.enum [ "off" "auto" "static" "rainbow" ];
      default = "static";
      description = ''
        Lighting mode applied at boot and after resume.

        - `off` — lights off
        - `auto` — firmware autonomous mode
        - `static` — solid `color` at `brightness`
        - `rainbow` — OEM rainbow (not available on all boards, e.g. M5406WA)
      '';
    };

    color = mkOption {
      type = types.strMatching "[0-9a-fA-F]{6}";
      default = "00d3b8";
      example = "00d3b8";
      description = "RGB color as RRGGBB (used in static mode)";
    };

    brightness = mkOption {
      type = types.ints.between 0 100;
      default = 100;
      description = "Brightness percent 0–100 (used in static mode)";
    };
  };

  config = mkIf cfg.enable (
    let
      vrgbCommand =
        if cfg.mode == "off" then
          "${getExe vrgb} off"
        else if cfg.mode == "auto" then
          "${getExe vrgb} auto on"
        else if cfg.mode == "rainbow" then
          "${getExe vrgb} rainbow on"
        else
          "${getExe vrgb} set ${cfg.color} ${toString cfg.brightness}";
    in
    {
      environment.systemPackages = [ vrgb ];
      services.udev.packages = [ vrgb ];

      systemd.services = {
        vivo-kbd-rgb = {
          description = "ASUS Vivobook keyboard RGB (vrgb)";
          wantedBy = [ "multi-user.target" ];
          after = [ "systemd-udev-settle.service" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStartPre = "${getExe' pkgs.coreutils "sleep"} 1";
            ExecStart = vrgbCommand;
          };
        };

        # Re-run vivo-kbd-rgb after wake
        vivo-kbd-rgb-wakeup = {
          description = "Restore ASUS Vivobook keyboard RGB after sleep";
          wantedBy = [ "sleep.target" ];
          after = [ "sleep.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${getExe' config.systemd.package "systemctl"} try-restart ${config.systemd.services.vivo-kbd-rgb.name}";
          };
        };
      };
    }
  );
}
