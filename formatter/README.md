# Project Nix formatter

Repository-local override of `nixfmt` with a compact formatting policy. Used by
`nix fmt` via the flake's `formatter` output.

## Style policy

- Two-space indentation, 120-column width, strict mode
- Lists of at most three simple items on one line when they fit
- Attribute sets with exactly one binding on one line when they fit
- Comment-free function parameter sets on one line when they fit
- Exactly two spaces before same-line `#` comments

Patches live in `nixfmt-compact.patch` and `nixfmt-line-width.patch`; width and
other defaults are set in `package.nix`.

## Usage

```console
nix fmt
```
