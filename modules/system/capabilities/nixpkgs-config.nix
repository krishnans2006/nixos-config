{ config, lib, ... }:

let
  cfg = config.modules.nixpkgs-config;

  # Filter out functions (e.g. packageOverrides, allowUnfreePredicate)
  # leaving only pure serializable settings
  serializableConfig = lib.filterAttrs (_: v: !builtins.isFunction v) config.nixpkgs.config;
in
{
  options.modules.nixpkgs-config = {
    enable = lib.mkEnableOption "Enable exporting nixpkgs.config to /etc/nix/nixpkgs-config.nix";
  };

  config = lib.mkIf cfg.enable {
    environment.etc."nix/nixpkgs-config.nix".text = ''
      # Generated automatically by modules.nixpkgs-config
      ${lib.generators.toPretty { } serializableConfig}
    '';
  };
}
