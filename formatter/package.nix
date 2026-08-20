{ lib, nixfmt, writeShellApplication, wrapWidth ? 40 }:

let
  patchedNixfmt = nixfmt.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./nixfmt-compact.patch
      ./nixfmt-line-width.patch
      ./nixfmt-lambda.patch
    ];
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/Nixfmt/Pretty.hs \
        --replace-fail '__WRAPWIDTH__' '${toString wrapWidth}'
    '';
  });
in
writeShellApplication {
  name = "nixfmt";
  runtimeInputs = [ patchedNixfmt ];
  text = ''
    exec ${lib.getExe patchedNixfmt} --strict --width=120 "$@"
  '';

  meta = patchedNixfmt.meta // {
    description = "Repository-specific compact Nix formatter";
    mainProgram = "nixfmt";
  };
}
