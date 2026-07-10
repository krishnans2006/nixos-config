{ config, lib, ... }:

with lib;

let
  cfg = config.modules.asusd;
in
{
  options.modules.asusd = {
    enable = mkEnableOption "ASUS laptop control via asusd and asusctl";

    chargeLimit = mkOption {
      type = types.ints.between 20 100;
      default = 80;
      description = "Battery charge stop threshold (20–100).";
    };
  };

  config = mkIf cfg.enable {
    # asusd.ron uses RON struct syntax (field: value,)
    # Only fields with #[serde(default)] in asusd/src/config.rs may be omitted
    # See https://gitlab.com/asus-linux/asusctl/-/blob/main/asusd/src/config.rs
    services.asusd = {
      enable = true;
      asusdConfig.text = ''
        (
          charge_control_end_threshold: ${toString cfg.chargeLimit},
          base_charge_control_end_threshold: ${toString cfg.chargeLimit},
          disable_nvidia_powerd_on_battery: true,
          ac_command: "",
          bat_command: "",
          platform_profile_linked_epp: true,
          platform_profile_on_battery: Quiet,
          change_platform_profile_on_battery: true,
          platform_profile_on_ac: Performance,
          change_platform_profile_on_ac: true,
          profile_quiet_epp: Power,
          profile_balanced_epp: BalancePower,
          profile_custom_epp: Performance,
          profile_performance_epp: Performance,
          ac_profile_tunings: {},
          dc_profile_tunings: {},
          armoury_settings: {},
        )
      '';
    };
  };
}
