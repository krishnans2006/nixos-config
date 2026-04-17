{ config, lib, ... }:

with lib;

let
  cfg = config.modules.ssh;
in
{
  options.modules.ssh = {
    enable = mkEnableOption "Enable custom SSH client configuration and known hosts";
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks = {
        "*" = {
          addKeysToAgent = "yes";
          # controlMaster = "auto";
          # controlPath = "~/.ssh/master-%r@%h:%p";
          # controlPersist = "3s";
        };
        "ews" = {
          hostname = "linux.ews.illinois.edu";
          identityFile = "~/.ssh/id_ed25519";
          user = "ks128";
          forwardX11 = true;
          forwardX11Trusted = true;
          extraOptions = {
            RequestTTY = "yes";
            RemoteCommand = "/bin/zsh";
          };
        };
        "ews-391" = {
          hostname = "eceb-3026.ews.illinois.edu";
          identityFile = "~/.ssh/id_ed25519";
          user = "ks128";
          forwardX11 = true;
          forwardX11Trusted = true;
          extraOptions = {
            RequestTTY = "yes";
            RemoteCommand = "/bin/zsh";
          };
        };
        "ncsa-delta" = {
          hostname = "login.delta.ncsa.illinois.edu";
          user = "krishnans2006";
          forwardX11 = true;
        };
        "oracle-amp" = {
          hostname = "150.136.13.65";
          identityFile = "~/.ssh/id_ed25519";
          user = "ubuntu";
        };
        "oracle-vm1" = {
          hostname = "150.136.122.56";
          identityFile = "~/.ssh/id_ed25519";
          user = "ubuntu";
        };
        "oracle-vm2" = {
          hostname = "129.153.27.23";
          identityFile = "~/.ssh/id_ed25519";
          user = "ubuntu";
        };
        "piserver.local" = {
          hostname = "piserver.local";
          user = "krishnan";
        };
        "tjfridge" = {
          hostname = "fridge.tjhsst.edu";  # 198.38.23.53
          user = "kshankar";
        };
        "tjras" = {
          hostname = "ras2.tjhsst.edu";  # 198.38.18.201
          user = "2024kshankar";
        };
      };
    };
  };
}
