# Project Nix formatter

Repository-local override of `nixfmt` with a compact formatting policy. It is
used by `nix fmt` via the flake's `formatter` output, and can also be installed
directly as `nixfmt`.

## Style policy

- Two-space indentation, 120-column width, strict mode
- Lists of at most six simple items on one line when they fit
- Attribute sets with exactly one binding on one line when they fit
- Lists of attribute sets always expand, even for a single item
- Comment-free function parameter sets on one line when they fit
- Exactly two spaces before same-line `#` comments
- Compact list and set forms are additionally gated by `wrapWidth` from
  `package.nix` (currently `45`), measured using the flattened literal content
  itself rather than indentation or surrounding assignment text
- Lambda applications such as `args: pkgs.buildFHSEnv (args // { ... })` prefer
  to keep `args // {` together when it fits

## Patches

- `nixfmt-compact.patch`: compact list/set behavior, forced multiline
  list-of-attrsets, two-space same-line comments, and the build-time
  `wrapWidth` gate for one-line collections
- `nixfmt-line-width.patch`: line-width accounting that uses the rendered line
  width rather than only the expression body
- `nixfmt-lambda.patch`: lambda and `//` absorption tweaks to keep forms like
  `args // {` and `buildFHSEnv = args: pkgs.buildFHSEnv (args // {` compact
  when they fit

Defaults such as `--strict`, `--width=120`, and `wrapWidth` are set in
`package.nix`.

## Usage

```sh
nix fmt
```
