{ inputs, root, ... }:

with inputs;

{
  imports = [
    # Base configuration
    "${root}/base/home.nix"

    # Profiles
    "${root}/profiles/desktop/home.nix"

    # Custom modules
    (import-tree "${root}/modules/home")
  ];

  # Custom config

  modules.plasma.hasBattery = false;

  modules.gaming = {
    enableLutris = true;
    enableMinecraft = true;
  };

  modules.packages.firefox.enable = true;
  programs.firefox.profiles.default.settings."identity.fxaccounts.account.device.name" =
    "krishnan-pc";

  services.flatpak.packages = [ "org.raspberrypi.rpi-imager" ];
}
