{ inputs, ... }:

with inputs;

{
  imports = [
    # Base configuration
    ../../base/home.nix

    # Custom modules
    (import-tree ../../modules/home)
  ];

  modules.plasma.enable = true;
  modules.tailscale.enable = true;
  modules.thunderbird.enable = false;
  
  programs.firefox.profiles.default.settings."identity.fxaccounts.account.device.name" = "krishnan-lap";

  programs.plasma.configFile.kwinrc.Xwayland.Scale = "1.25";
}
