{ lib, nixfmt, writeShellApplication }:

let
  patchedNixfmt = nixfmt.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./nixfmt-compact.patch ./nixfmt-line-width.patch ];
  });
in
writeShellApplication {
  name = "nixfmt";
  runtimeInputs = [ patchedNixfmt ];
  text = ''
    exec ${lib.getExe patchedNixfmt} --strict --width=95 "$@"
  '';

  meta = patchedNixfmt.meta // {
    description = "Repository-specific compact Nix formatter";
    mainProgram = "nixfmt";
  };
}
