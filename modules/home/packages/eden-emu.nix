{ config, lib, osConfig, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.eden-emu;

  # Eden forked discord-rpc and made a few changes
  # https://github.com/eden-emulator/discord-rpc/pull/1
  # So we override to their fork
  discord-rpc = pkgs.discord-rpc.overrideAttrs {
    version = "3.4.0-eden";
    src = pkgs.fetchFromGitHub {
      owner = "eden-emulator";
      repo = "discord-rpc";
      rev = "76616d8675d8be04a0821783dbf5950ad05e6df2";
      hash = "sha256-JUfxDO1JaGl66S0NIYm3UDq1N5nVZNvsYJi5ZeqiXTY=";
    };
    # The fork already includes the nixpkgs patches
    patches = [ ];
    postPatch = "";
  };

  # This enables Discord rich presence in Eden
  # See https://git.eden-emu.dev/eden-emu/eden/src/commit/d85bad89248fcae68f812d7e1c937436261404cb/docs/Options.md
  eden-emu = pkgs.eden.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ discord-rpc ];
    cmakeFlags = old.cmakeFlags ++ [ (cmakeBool "USE_DISCORD_PRESENCE" true) ];
  });

  verify-system = import (root + "/utils/verify-system.nix") {
    inherit lib osConfig;
    option = "modules.eden-emu.enable";
    type = "optional";
    reason = "to open the firewall port for Eden multiplayer";
  };
in
{
  options.modules.eden-emu = {
    enable = mkEnableOption "Install Eden Emulator";
  };

  config = mkIf cfg.enable (
    verify-system.apply {
      home.packages = [ eden-emu ];

      # Settings/controller profiles, saves/NAND/keys/mods, and game library.
      modules.impermanence.persistDirs = [
        ".config/eden"
        ".local/share/eden"
        "Games"
      ];
    }
  );
}
