{ import-tree, root, ... }:

{
  imports = [
    # Custom modules
    (import-tree "${root}/modules/system")
  ];

  modules.krishnan-user = {
    enable = true;
    enablePresetPassword = false;
  };

  modules.networking.enable = true;
  modules.ssh-server.enable = true;
  modules.tailscale = {
    enable = true;
    enableNMIntegration = false;
    enableTaildrive = false;
  };
}
