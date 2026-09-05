{ root, ... }:

{
  imports = [ "${root}/profiles/home-only/home.nix" ];

  home = {
    username = "ks128";
    homeDirectory = "/home/ks128";
  };

  # Since it's not NixOS
  targets.genericLinux = {
    enable = true;
    gpu.enable = false;
  };
}
