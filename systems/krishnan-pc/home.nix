{ inputs, pkgs, root, ... }:

with inputs;

{
  imports = [
    # Profiles
    (root + "/profiles/base/home.nix")
    (root + "/profiles/default/home.nix")
    (root + "/profiles/desktop/home.nix")

    # Custom modules
    (import-tree (root + "/modules/home"))
  ];

  # Custom config

  modules.plasma.hasBattery = false;

  modules.lutris.enable = true;
  modules.minecraft.enable = true;
  modules.dolphin-emu.enable = true;

  modules.firefox.enable = true;
  modules.aethersdr.enable = true;

  programs.firefox.profiles.default.settings."identity.fxaccounts.account.device.name" =
    "krishnan-pc";

  services.flatpak.packages = [ "org.raspberrypi.rpi-imager" ];

  home.packages = with pkgs; [
    llama-cpp-rocm
    eden
    #
  ];
}
