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
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users."krishnan" = {
      uid = 1000;
      isNormalUser = true;
      description = "Krishnan Shankar";
      
      # networkmanager, wheel: initially set (in configuration.nix)
      # dialout: for serial/USB ports
      # fuse: for sshfs (TODO: modularize)
      extraGroups = [ "networkmanager" "wheel" "dialout" "fuse" ];
      packages = with pkgs; [ ];  # Managed by home-manager
      shell = pkgs.zsh;
    };
    security.sudo.wheelNeedsPassword = false;

    # Shell
    programs.zsh.enable = true;
    environment.pathsToLink = [ "/share/zsh" ];
  };
}
