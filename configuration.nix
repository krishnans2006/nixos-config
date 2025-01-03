# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Memtest86+
  boot.loader.grub.memtest86.enable = true;

  # Swappiness
  boot.kernel.sysctl = {
    "vm.swappiness" = 15;
  };

  # Disable dev-tpmrm0.device
  # See https://github.com/systemd/systemd/issues/33412
  systemd.units."dev-tpmrm0.device".enable = false;

  # Hostname should be defined in device-specific nix file!
  # networking.hostName = "krishnan-nix"; # Define your hostname.

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  #time.timeZone = "America/Chicago";
  services.automatic-timezoned.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Fix blurry vscode
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;

    #wireplumber.extraConfig."10-bluez" = {
    #  "monitor.bluez.properties" = {
    #    "bluez5.enable-sbc-xq" = true;
    #    "bluez5.enable-msbc" = true;
    #    "bluez5.enable-hw-volume" = true;
    #    "bluez5.roles" = [
    #      "hsp_hs"
    #      "hsp_ag"
    #      "hfp_hf"
    #      "hfp_ag"
    #    ];
    #  };
    #};
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  # A2DP
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
      FastConnectable = "true";
      MultiProfile = "multiple";
      Experimental = true;
    };
  };
  #services.blueman.enable = true;

  # udev rules
  services.udev.packages = with pkgs; [
    platformio-core
    openocd
    via
  ];

  # Shell
  programs.zsh.enable = true;
  environment.pathsToLink = [ "/share/zsh" ];

  # Enable KDE Connect (Phone Integration)
  programs.kdeconnect.enable = true;
  #networking.firewall = rec {
  #  allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
  #  allowedUDPPortRanges = allowedTCPPortRanges;
  #};

  # Enable Partition Manager
  programs.partition-manager.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.krishnan = {
    isNormalUser = true;
    description = "Krishnan Shankar";
    extraGroups = [ "networkmanager" "wheel" "dialout" ];
    packages = with pkgs; [ ];
    shell = pkgs.zsh;
  };
  security.sudo.wheelNeedsPassword = false;

  # Install firefox.
  #programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    gnupg
  ];

  services.flatpak.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.tailscale.enable = true;

  services.redis.servers."".enable = true;
  programs.firejail.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;  # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true;  # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true;  # Open ports in the firewall for Steam Local Network Game Transfers
  };

  networking.wg-quick.interfaces.proton = {
    autostart = false;
    configFile = "/home/krishnan/.config/wireguard/proton.conf";
  };
  systemd.services."wg-quick-proton".preStart = ''
    while [ ! -f /home/krishnan/.config/wireguard/proton.conf ]; do
      sleep 1
    done
  '';
  networking.wg-quick.interfaces.tjcsl = {
    autostart = false;
    configFile = "/home/krishnan/.config/wireguard/tjcsl.conf";
  };
  systemd.services."wg-quick-tjcsl".preStart = ''
    while [ ! -f /home/krishnan/.config/wireguard/tjcsl.conf ]; do
      sleep 1
    done
  '';

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
