{ pkgs }:

let
  inherit (pkgs) lib treefmt writeShellApplication;

  nixfmt = pkgs.callPackage ./package.nix { };

  treefmtWithConfig = treefmt.withConfig {
    runtimeInputs = [ nixfmt ];
    settings = {
      on-unmatched = "info";
      formatter.nixfmt = {
        command = "nixfmt";
        includes = [ "*.nix" ];
      };
    };
  };
in
writeShellApplication {
  name = "treefmt";
  runtimeInputs = [ treefmtWithConfig ];

  # treefmt caches by file content, not by the formatter binary. Bypass the
  # cache so changes to package.nix or its patches take effect immediately.
  text = ''
    exec ${lib.getExe treefmtWithConfig} --no-cache "$@"
  '';

  meta = treefmtWithConfig.meta // {
    description = "Repository Nix formatter via treefmt";
    mainProgram = "treefmt";
  };
}
