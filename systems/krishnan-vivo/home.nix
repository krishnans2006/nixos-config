{ inputs, pkgs, root, ... }:

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
    "krishnan-vivo";

  modules.impermanence.enable = true;

  modules.gaming = {
    enableLutris = false;
    enableMinecraft = true;
  };

  modules.packages.zed-editor.fontSize = 14;

  programs.plasma.configFile.kwinrc.Xwayland.Scale = "1.25";
  programs.plasma.input.keyboard.model = "asus_laptop";
  programs.plasma.input.touchpads = [
    {
      enable = true;
      vendorId = "2808";
      productId = "0233";
      name = "ASCF1200:00 2808:0233 Touchpad";
      naturalScroll = true;
    }
  ];

  services.flatpak.packages = [ "org.raspberrypi.rpi-imager" ];

  home.packages = with pkgs; [ kdePackages.kdenlive ];
}
