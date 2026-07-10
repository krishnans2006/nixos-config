{ config, lib, inputs, ... }:

with lib;

let
  cfg = config.modules.asusd;

  ronix = inputs.ronix.lib;

  # Complete, valid asusd::config::Config on its own
  # See asusd/src/config.rs in https://gitlab.com/asus-linux/asusctl
  # If these fields aren't always present, asusd will fail to parse the file
  # and reset everything to defaults, which is stupid but oh well
  # Optional fields with #[serde(default)] are omitted
  asusdSettings = {
    charge_control_end_threshold = 100;
    disable_nvidia_powerd_on_battery = true;
    ac_command = "";
    bat_command = "";
    platform_profile_linked_epp = true;
    platform_profile_on_battery = ronix.mkRON "enum" "Quiet";
    change_platform_profile_on_battery = true;
    platform_profile_on_ac = ronix.mkRON "enum" "Performance";
    change_platform_profile_on_ac = true;
    profile_quiet_epp = ronix.mkRON "enum" "Power";
    profile_balanced_epp = ronix.mkRON "enum" "BalancePower";
    profile_custom_epp = ronix.mkRON "enum" "Performance";
    profile_performance_epp = ronix.mkRON "enum" "Performance";
    ac_profile_tunings = ronix.mkRON "map" [ ];
    dc_profile_tunings = ronix.mkRON "map" [ ];
    armoury_settings = ronix.mkRON "map" [ ];
  };
in
{
  options.modules.asusd = {
    enable = mkEnableOption "ASUS laptop control via asusd and asusctl";

    chargeLimit = mkOption {
      type = types.ints.between 20 100;
      default = 100;
      description = "Battery charge stop threshold (20–100).";
    };
  };

  config = mkIf cfg.enable {
    services.asusd = {
      enable = true;
      asusdConfig.text = ronix.toRON 0 (asusdSettings // {
        charge_control_end_threshold = cfg.chargeLimit;
        base_charge_control_end_threshold = cfg.chargeLimit;
      });
    };
  };
}
