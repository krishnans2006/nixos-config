{ pkgs }:
let
  lib = pkgs.lib;
  nixfmt = pkgs.callPackage ./package.nix { };

  treefmtWithConfig = pkgs.treefmt.withConfig {
    runtimeInputs = [ nixfmt ];
    settings = {
      on-unmatched = "info";
      formatter.nixfmt = {
        command = "nixfmt";
        includes = [ "*.nix" ];
      };
    };
  };

  # treefmt's eval cache keys on file content, not the formatter binary, so
  # changing --width in package.nix is ignored unless we bypass cache.
  formatter = pkgs.writeShellApplication {
    name = "treefmt";
    runtimeInputs = [ treefmtWithConfig ];
    text = ''
      exec ${lib.getExe treefmtWithConfig} --no-cache "$@"
    '';
    meta = treefmtWithConfig.meta // { mainProgram = "treefmt"; };
  };
in
formatter
