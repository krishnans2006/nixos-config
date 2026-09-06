{ pkgs, ... }:

{
  # Swappiness
  boot.kernel.sysctl = {
    "vm.swappiness" = 15;
    "fs.inotify.max_user_watches" = 1048576;
  };

  # Disable dev-tpmrm0.device
  # See https://github.com/systemd/systemd/issues/33412
  systemd.units."dev-tpmrm0.device".enable = false;

  # TODO: check if necessary
  hardware.enableAllFirmware = true;

  # udev rules
  services.udev.packages = with pkgs; [
    platformio-core
    openocd
    via
    probe-rs-tools
  ];

  # Temporary fix until Zulip upgrades to Electron 40+
  # Must be set at the system level since home-manager.useGlobalPkgs = true
  nixpkgs.config.permittedInsecurePackages = [ "electron-39.8.10" ];

  services.redis.servers."".enable = true;
  programs.firejail.enable = true;

  # LLDB fix
  #nixpkgs.overlays = [
  #  (final: prev: {
  #    lldb = prev.lldb.overrideAttrs {
  #      dontCheckForBrokenSymlinks = true;
  #    };
  #  })
  #];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
}
