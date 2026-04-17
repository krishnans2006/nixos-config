{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.packages.utils;
in
{
  options.modules.packages.utils = {
    enable = mkEnableOption "Enable common shell utilities";
  };

  # This module just bundles a lot of shell utils that have been used at some point
  # A lot can probably be removed (and used with comma) - that's a task for the future

  config = mkIf cfg.enable {
    home.packages = with pkgs; [

      # it provides the command `nom` works just like `nix`
      # with more details log output
      nix-output-monitor

      fastfetch

      zip
      xz
      unzip
      p7zip

      file
      which
      tree
      gnused
      gnutar
      htop
      ncdu

      ffmpeg

      wl-clipboard

      jq

      undollar
      moreutils

      wireguard-tools

      dig
      nmap

      libxml2

      gh
      git-lfs
      git-subrepo
      git-filter-repo
      meld
      kdiff3

      rclone

      lm_sensors # for `sensors` command
      memtester

      devenv
    ];
  };
}
