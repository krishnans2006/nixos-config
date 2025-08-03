{ config, pkgs, ... }:

{
  imports = [
    ./config/secrets.nix

    ./modules/plasma.nix
    ./modules/networks.nix
    ./modules/gaming.nix
  ];

  modules.plasma.enable = true;
  modules.networks.enable = true;
  modules.gaming.enable = false;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Memtest86+
  boot.loader.grub.memtest86.enable = true;

  # Swappiness
  boot.kernel.sysctl = {
    "vm.swappiness" = 15;
    "fs.inotify.max_user_watches" = 1048576;
  };

  # Disable dev-tpmrm0.device
  # See https://github.com/systemd/systemd/issues/33412
  systemd.units."dev-tpmrm0.device".enable = false;

  # Yubikey Auth (see yubikey/u2f_keys in secrets-home)
  security.pam.services = {
    login.u2fAuth = true;
    # sudo.u2fAuth = true;  # sudo is passwordless, so no need for U2F
  };

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

  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Printer autodiscovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

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
  hardware.enableAllFirmware = true;
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

  # HP Pen
  hardware.opentabletdriver = {
    enable = true;
    daemon.enable = true;
  };

  # udev rules
  services.udev.packages = with pkgs; [
    platformio-core
    openocd
    via
  ];

  # Docker
  virtualisation.docker = {
    enable = true;
  };

  # Waydroid (Android apps)
  virtualisation.waydroid.enable = true;

  # Shell
  programs.zsh.enable = true;
  environment.pathsToLink = [ "/share/zsh" ];

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."krishnan" = {
    uid = 1000;
    isNormalUser = true;
    description = "Krishnan Shankar";
    extraGroups = [ "networkmanager" "wheel" "dialout" "fuse" "docker" "davfs2" ];
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
  services.davfs2 = {
    enable = true;
    davGroup = "davfs2";
  };

  services.redis.servers."".enable = true;
  programs.firejail.enable = true;

  # fstab entries for mounts
  fileSystems."/home/krishnan/Filesystems/Tailscale" = {
    device = "http://100.100.100.100:8080";
    mountPoint = "/home/krishnan/Filesystems/Tailscale";
    depends = [ "/" ];
    noCheck = true;
    fsType = "davfs";
    options = [ "_netdev" "rw" "file_mode=0664" "dir_mode=2775" "user" "uid=${toString config.users.users."krishnan".uid}" "grpid" ];
  };
  environment.etc."davfs2/secrets" = {
    enable = true;
    text = "http://100.100.100.100:8080 \"\" \"\"";
    mode = "0600";
  };

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
