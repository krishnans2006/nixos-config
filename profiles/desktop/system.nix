{ import-tree, root, ... }:

{
  imports = [
    # Custom modules
    (import-tree "${root}/modules/system")
  ];

  modules.secrets.enable = true;

  modules.krishnan-user = {
    enable = true;
    enablePresetPassword = true;
  };

  modules.plasma.enable = true;
  modules.audio.enable = true;
  modules.bluetooth.enable = true;

  modules.networking.enable = true;
  modules.networks.enable = true;
  modules.tailscale = {
    enable = true;
    enableNMIntegration = true;
    enableTaildrive = false;
  };

  modules.printing.enable = true;
  modules.docker.enable = true;
  modules.iphone.enable = true;
}
