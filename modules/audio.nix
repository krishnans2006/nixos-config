{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.audio;
in
{
  options.modules.audio = {
    enable = mkEnableOption "Enable audio/sound using pipewire";
  };

  config = mkIf cfg.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;

      #wireplumber.extraConfig."10-bluez" = {
      #  "monitor.bluez.properties" = {
      #    "bluez5.enable-sbc-xq" = true;
      #    "bluez5.enable-msbc" = true;
      #    "bluez5.enable-hw-volume" = true;
      #    "bluez5.roles" = [
      #      "hsp_hs"
      #      "hsp_ag"
      #      "hfp_hf"
      #      "hfp_ag"
      #    ];
      #  };
      #};
    };
  };
}
