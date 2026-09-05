{ inputs, root, ... }:

with inputs;

{
  imports = [
    # Base configuration
    "${root}/base/home.nix"

    # Custom modules
    (import-tree "${root}/modules/home")

    # Profiles
    "${root}/profiles/desktop/home.nix"
  ];

  # Custom config

  programs.firefox.profiles.default.settings."identity.fxaccounts.account.device.name" =
    "krishnan-lap";

  modules.impermanence.enable = true;

  modules.plasma.hasBattery = false;

  programs.plasma.configFile.kwinrc.Xwayland.Scale = "1.25";

  programs.plasma.input.touchpads = [
    {
      enable = false;
      vendorId = "0002";
      productId = "0007";
      name = "SynPS/2 Synaptics TouchPad";
      naturalScroll = true;
    }
  ];
}
