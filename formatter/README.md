# Project Nix formatter

This is a thin, repository-local override of the `nixfmt` package from the
pinned `nixpkgs` input. It retains nixfmt's parser, layout engine, strict mode,
and verification checks while applying this repository's compact formatting
policy.

## Style policy

- Format deterministically with two-space indentation and a 120-column width.
- Keep lists of at most three simple items on one line when they fit.
- Keep attribute sets with exactly one binding on one line when they fit.
- Keep comment-free function parameter sets on one line when they fit,
  independently of their item count and original layout.
- Put exactly two spaces before same-line `#` comments.
- Let comments, blank-line grouping, multiline values, and the width limit force
  collections onto multiple lines. Width counts the full line including indentation.
  Compact lists and sets ignore the previous input layout, so raising the width
  limit can collapse them again after a narrower pass.
- Use upstream nixfmt behavior for all other syntax.

The wrapper always supplies `--strict --width=120`. Additional arguments are
forwarded to the patched nixfmt executable.

## Usage

Format all Nix files in the repository:

```console
nix fmt
```

Check formatting and formatter invariants:

```console
nix flake check
```

Format or check individual files:

```console
nix run .#nixfmt -- file.nix
nix run .#nixfmt -- --check file.nix
nix run .#nixfmt -- --verify file.nix
```

## Maintenance

The implementation is in `nixfmt-compact.patch` and `nixfmt-line-width.patch`;
`package.nix` applies them to the pinned nixfmt source. A nixpkgs update that
changes the affected nixfmt source should fail while applying the patch instead
of silently changing the project style.

After updating nixpkgs:

1. Build `.#nixfmt` to confirm the patch still applies.
2. Run `nix flake check` to exercise the golden style fixture, AST-equivalence
   verification, idempotence, and the repository-wide formatting check.
3. Review any formatter diff before accepting the update.
