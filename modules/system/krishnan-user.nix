{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.krishnan-user;
in
{
  options.modules.krishnan-user = {
    enable = mkEnableOption "Enable the krishnan user (with zsh)";
  };

  config = mkIf cfg.enable {
    users.mutableUsers = false;

    # Disable root login (sudo only)
    users.users."root".hashedPassword = null;

    users.users."krishnan" = {
      uid = 1000;
      isNormalUser = true;
      description = "Krishnan Shankar";
      hashedPasswordFile = config.sops.secrets."password".path;

      # networkmanager, wheel: initially set (in configuration.nix)
      # dialout: for serial/USB ports
      extraGroups = [ "networkmanager" "wheel" "dialout" ];
      packages = [ ];  # Managed by home-manager
      shell = pkgs.zsh;

      # See ssh-server.nix
      openssh.authorizedKeys.keys = [
        # krishnan-pc
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPzvD6itrqgr9qqNVao8XnuRX3dLH9rUTf9xMydB9VG3 krishnans2006@gmail.com"
        # krishnan-lap
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ37RZ3TIIuDNS3wcaQ4t0z5NkT1H4GukVcke3GNOn40 krishnans2006@gmail.com"
        # krishnan-vivo
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEjk4Ah+IsWbXjwpA89sL1s01UdJoobtFlpeBxcHJkTj krishnans2006@gmail.com"
        # krishnan-pi
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDZgsLeuVcdgehuhwpO8ZZuzPzTQhPGjYcrnzLSBCCP2 krishnans2006@gmail.com"
      ];
    };
    security.sudo.wheelNeedsPassword = false;

    # Shell
    programs.zsh.enable = true;
    environment.pathsToLink = [ "/share/zsh" ];
  };
}
