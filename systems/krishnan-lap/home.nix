{ ... }:

{
  imports = [
    # Custom modules
    ../../modules/plasma-home.nix
    ../../modules/tailscale-home.nix

    # Base configuration
    ../../base/home.nix
  ];

  modules.plasma.enable = true;
  modules.tailscale.enable = true;
  
  programs.firefox.profiles.default.settings."identity.fxaccounts.account.device.name" = "krishnan-lap";
}
