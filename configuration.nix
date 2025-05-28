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
    "fs.inotify.max_user_watches" = 1048576;
  };

  # Disable dev-tpmrm0.device
  # See https://github.com/systemd/systemd/issues/33412
  systemd.units."dev-tpmrm0.device".enable = false;

  # Secrets
  sops = {
    age.keyFile = "/home/krishnan/.config/sops/age/keys.txt";
    age.generateKey = false;  # Do it manually from an SSH key (see README.md)
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    secrets = {
      "wireguard/tjcsl" = {
        restartUnits = [ "wg-quick-tjcsl.service" ];
      };
      "wireguard/proton" = {
        restartUnits = [ "wg-quick-proton.service" ];
      };
      "wireguard/surfshark" = {
        restartUnits = [ "wg-quick-surfshark.service" ];
      };
      "networks" = {
        restartUnits = [ "NetworkManager.service" ];
      };
    };
  };

  # Networking
  networking = {
    nameservers = [ "1.1.1.1" "1.0.0.1" ];

    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      wifi.backend = "wpa_supplicant";

      ensureProfiles = {
        environmentFiles = [ config.sops.secrets."networks".path ];

        profiles = {
          net0 = {
            connection.type = "wifi";
            wifi.mode = "infrastructure";
            connection.id = "$net0_name";
            wifi.ssid = "$net0_ssid";
            wifi-security.key-mgmt = "wpa-psk";
            wifi-security.psk = "$net0_psk";
            ipv4.method = "auto";
            ipv4.dns = "1.1.1.1;1.0.0.1;";
            ipv4.ignore-auto-dns = "true";
          };
          net1 = {
            connection.type = "wifi";
            wifi.mode = "infrastructure";
            connection.id = "$net1_name";
            wifi.ssid = "$net1_ssid";
            wifi-security.key-mgmt = "wpa-psk";
            wifi-security.psk = "$net1_psk";
            ipv4.method = "auto";
            ipv4.dns = "1.1.1.1;1.0.0.1;";
            ipv4.ignore-auto-dns = "true";
          };
          net2 = {
            connection.type = "wifi";
            wifi.mode = "infrastructure";
            connection.id = "$net2_name";
            wifi.ssid = "$net2_ssid";
            wifi-security.key-mgmt = "wpa-eap";
            "802-1x".eap = "$net2_eap";
            "802-1x".phase2-auth = "$net2_phase2_auth";
            "802-1x".identity = "$net2_identity";
            "802-1x".password = "$net2_password";
            ipv4.method = "auto";
            ipv4.dns = "1.1.1.1;1.0.0.1;";
            ipv4.ignore-auto-dns = "true";
          };
          net3 = {
            connection.type = "wifi";
            wifi.mode = "infrastructure";
            connection.id = "$net3_name";
            wifi.ssid = "$net3_ssid";
            wifi-security.key-mgmt = "wpa-eap";
            "802-1x".eap = "$net3_eap";
            "802-1x".phase2-auth = "$net3_phase2_auth";
            "802-1x".identity = "$net3_identity";
            "802-1x".password = "$net3_password";
            ipv4.method = "auto";
            ipv4.dns = "1.1.1.1;1.0.0.1;";
            ipv4.ignore-auto-dns = "true";
          };
          net4 = {
            connection.type = "wifi";
            wifi.mode = "infrastructure";
            connection.id = "$net4_name";
            wifi.ssid = "$net4_ssid";
            wifi-security.key-mgmt = "wpa-psk";
            wifi-security.psk = "$net4_psk";
            ipv4.method = "auto";
            ipv4.dns = "1.1.1.1;1.0.0.1;";
            ipv4.ignore-auto-dns = "true";
          };
          net5 = {
            connection.type = "wifi";
            wifi.mode = "infrastructure";
            connection.id = "$net5_name";
            wifi.ssid = "$net5_ssid";
            wifi-security.key-mgmt = "wpa-psk";
            wifi-security.psk = "$net5_psk";
            ipv4.method = "auto";
            ipv4.dns = "1.1.1.1;1.0.0.1;";
            ipv4.ignore-auto-dns = "true";
          };
          net6 = {
            connection.type = "wifi";
            wifi.mode = "infrastructure";
            connection.id = "$net6_name";
            wifi.ssid = "$net6_ssid";
            wifi-security.key-mgmt = "wpa-psk";
            wifi-security.psk = "$net6_psk";
            ipv4.method = "auto";
            ipv4.dns = "1.1.1.1;1.0.0.1;";
            ipv4.ignore-auto-dns = "true";
          };
          net7 = {
            connection.type = "wifi";
            wifi.mode = "infrastructure";
            connection.id = "$net7_name";
            wifi.ssid = "$net7_ssid";
            wifi-security.key-mgmt = "wpa-psk";
            wifi-security.psk = "$net7_psk";
            ipv4.method = "auto";
            ipv4.dns = "1.1.1.1;1.0.0.1;";
            ipv4.ignore-auto-dns = "true";
          };
        };
      };
    };

    wireless.enable = false;

    wg-quick.interfaces = {
      tjcsl = {
        autostart = true;
        configFile = config.sops.secrets."wireguard/tjcsl".path;
      };
      proton = {
        autostart = false;
        configFile = config.sops.secrets."wireguard/proton".path;
      };
      surfshark = {
        autostart = false;
        configFile = config.sops.secrets."wireguard/surfshark".path;
      };
    };
  };

  services.resolved = {
    enable = true;
    domains = [ "~." ];
    fallbackDns = [ "1.1.1.1" "1.0.0.1" ];
    dnssec = "allow-downgrade";
    dnsovertls = "opportunistic";  # maybe "true" is possible?
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

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager = {
    sddm.enable = true;
    autoLogin.enable = true;
    autoLogin.user = "krishnan";
  };
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

  # Enable KDE Connect (Phone Integration)
  programs.kdeconnect.enable = true;

  # Enable Partition Manager
  programs.partition-manager.enable = true;

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

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;  # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true;  # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true;  # Open ports in the firewall for Steam Local Network Game Transfers
  };

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
