{ ... }:

{
  imports = [
    # Custom modules
    ../../modules/plasma-home.nix

    # Base configuration
    ../../base/home.nix
  ];

  modules.plasma.enable = true;
  
  programs.firefox.profiles.default.settings."identity.fxaccounts.account.device.name" = "krishnan-lap";
}
