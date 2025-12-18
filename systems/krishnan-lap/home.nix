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
  
  programs.firefox.profiles.default.settings."identity.fxaccounts.account.device.name" = "krishnan-lap";

  programs.plasma.configFile.kwinrc.Xwayland.Scale = "1.25";
}
