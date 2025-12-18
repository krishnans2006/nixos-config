{ ... }:

{
  imports = [
    # Custom modules
    ../../modules/plasma-home.nix
    ../../modules/tailscale-home.nix
    ../../modules/thunderbird-home.nix

    # Base configuration
    ../../base/home.nix
  ];

  modules.plasma.enable = true;
  modules.tailscale.enable = true;
  modules.thunderbird.enable = false;

  programs.firefox.profiles.default.settings."identity.fxaccounts.account.device.name" = "krishnan-vivo";

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
}
