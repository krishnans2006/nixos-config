{ config, lib, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.vivo-kbd-rgb;

  vrgb = pkgs.callPackage "${root}/custom/vrgb.nix" { };
  vrgb-rainbow = pkgs.callPackage "${root}/custom/vrgb-rainbow.nix" { inherit vrgb; };
in
{
  options.modules.vivo-kbd-rgb = {
    enable = mkEnableOption "ASUS Vivobook keyboard RGB via vrgb (HID LampArray / ITE5570)";

    mode = mkOption {
      type = types.enum [ "off" "auto" "static" "rainbow" ];
      default = "static";
      description = ''
        Lighting mode applied at boot and after resume.

        - `off` --- lights off
        - `auto` --- firmware autonomous mode
        - `static` --- solid `color` at `brightness`
        - `rainbow` --- software hue cycle over `rainbowPeriod`
      '';
    };

    color = mkOption {
      type = types.strMatching "[0-9a-fA-F]{6}";
      default = "0b6623";
      example = "00d3b8";
      description = "RGB color as RRGGBB (used in static mode)";
    };

    brightness = mkOption {
      type = types.ints.between 0 100;
      default = 100;
      description = "Brightness percent 0–100 (used in static and rainbow modes)";
    };

    rainbowPeriod = mkOption {
      type = types.numbers.positive;
      default = 12;
      example = 8;
      description = "Seconds for one full rainbow cycle (rainbow mode only)";
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
          "${getExe vrgb-rainbow} --period ${toString cfg.rainbowPeriod} --brightness ${toString cfg.brightness}"
        else
          "${getExe vrgb} set ${cfg.color} ${toString cfg.brightness}";

      sleep = "${getExe' pkgs.coreutils "sleep"}";
      systemctl = "${getExe' config.systemd.package "systemctl"}";
    in
    {
      environment.systemPackages = [ vrgb vrgb-rainbow ];
      services.udev.packages = [ vrgb ];

      systemd.services = mkMerge [
        {
          vivo-kbd-rgb = {
            description = "ASUS Vivobook keyboard RGB (vrgb)";
            wantedBy = [ "multi-user.target" ];
            after = [ "systemd-udev-settle.service" ];
            serviceConfig.ExecStart = vrgbCommand;
          };
        }

        (mkIf (cfg.mode != "rainbow") {
          vivo-kbd-rgb.serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStartPre = "${sleep} 1";
          };

          # Re-run vivo-kbd-rgb after wake
          vivo-kbd-rgb-wakeup = {
            description = "Restore ASUS Vivobook keyboard RGB after sleep";
            wantedBy = [ "sleep.target" ];
            after = [ "sleep.target" ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${systemctl} try-restart ${config.systemd.services.vivo-kbd-rgb.name}";
            };
          };
        })

        (mkIf (cfg.mode == "rainbow") {
          vivo-kbd-rgb.serviceConfig = {
            Type = "simple";
            Restart = "on-failure";
            RestartSec = "2s";
          };
        })
      ];
    }
  );
}
