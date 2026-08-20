# Project Nix formatter

This directory contains a repository-local override of upstream `nixfmt`. The
goal is not to invent a new formatting style everywhere, but to keep a small
set of recurring patterns more compact and easier to scan in this codebase.

The formatter is exposed through the flake's `formatter` output, so `nix fmt`
from the repository root uses it automatically.

## Defaults

The wrapper in `package.nix` runs `nixfmt` with:

- `--strict`
- `--width=120`
- `wrapWidth = 45` as an extra project-specific compaction limit

`wrapWidth` is a build-time setting used only by the compact-list and
compact-set logic described below. It measures the flattened literal content
itself, not surrounding indentation or assignment text. For example, a list like `[ git curl wget ]` has a flattened length of 17.

## Deviations From Stock `nixfmt`

### 1. Short simple lists may stay on one line

Stock `nixfmt` tends to expand general lists eagerly. This formatter keeps a
list on one line when all of the following are true:

- the list has at most 6 items
- every item is simple
- the flattened list fits within `wrapWidth`

This is meant to keep routine package lists and short option lists readable
without turning larger collections into dense one-liners.

Example:

```nix
# custom formatter
buildInputs = [ git curl wget ripgrep fd ];

# stock nixfmt is more likely to expand this vertically
buildInputs = [
  git
  curl
  wget
  ripgrep
  fd
];
```

### 2. Singleton attribute sets may stay on one line

Upstream `nixfmt` already allows some compact set layouts in limited cases. This
formatter makes that behavior more deliberately available for sets with exactly
one binding, again gated by `wrapWidth`.

This keeps tiny configuration records concise while still expanding larger sets.

Example:

```nix
# custom formatter
meta = { mainProgram = "nixfmt"; };

# expanded once the set stops being tiny
meta = {
  description = "Repository-specific compact Nix formatter";
  mainProgram = "nixfmt";
};
```

### 3. Lists of attribute sets always expand

This is the main exception to the compact-list rule. Even a single attrset
inside a list forces multiline layout.

The reason is readability: inline lists of attrsets become hard to scan very
quickly, especially in module definitions and package metadata.

Example:

```nix
# custom formatter
remotes = [
  {
    name = "flathub";
    location = "https://flathub.org/repo/flathub.flatpakrepo";
  }
];
```

Instead of:

```nix
remotes = [ { name = "flathub"; location = "https://flathub.org/repo/flathub.flatpakrepo"; } ];
```

### 4. Same-line comments use two spaces before `#`

Upstream `nixfmt` emits one space before a trailing `#` comment. This formatter
uses two spaces.

This is a purely stylistic deviation.

Example:

```nix
# custom formatter
foo = "bar";  # explanation

# stock nixfmt
foo = "bar"; # explanation
```

### 5. Function parameter sets may flatten more often

For attribute-set parameters, this formatter is less conservative about keeping
the parameter list itself on one line, as long as the parameters have no trivia
that would make the result ambiguous or messy.

It still keeps upstream's conservative rule for whether the function body can be
absorbed onto the same line.

Example:

```nix
# custom formatter
{ pkgs, lib, ... }:
{
  # body...
}
```

This is mainly intended to avoid unnecessary vertical expansion of routine
module argument sets.

### 6. Lambda and update-expression absorption is more aggressive

This formatter adds special handling so expressions like `args // { ... }` stay
compact in places where upstream `nixfmt` tends to break them apart.

This matters most for wrappers around helper functions such as
`pkgs.buildFHSEnv`, where the shape `args: f (args // { ... })` is common.

Examples:

```nix
# custom formatter
args: pkgs.buildFHSEnv (args // {
  name = "foo";
})
```

```nix
# custom formatter
buildFHSEnv = args: pkgs.buildFHSEnv (args // {
  name = "foo";
});
```

There is also a related tweak for simple identifier-parameter lambdas so forms
like `name = arg:` prefer to keep `arg:` on the same line even when the body
must break.

Example:

```nix
# custom formatter
mapPackage = pkg:
  {
    inherit pkg;
  };
```

### 7. Line-width checks count indentation

The compacting logic above uses `wrapWidth`, but the underlying line-fitting
logic is also patched.

Stock `nixfmt` can decide that something fits because it measures only the text
added after the current indentation. This formatter counts the full rendered
line length, including indentation, when deciding whether soft breaks should
collapse.

This makes width decisions closer to what a human sees on screen.

## Patch map

- `nixfmt-compact.patch`
  Adds compact list/set behavior, the `wrapWidth` gate, forced multiline
  list-of-attrsets, two-space same-line comments, and relaxed flattening for
  some parameter sets.
- `nixfmt-line-width.patch`
  Makes width calculations account for indentation in rendered lines.
- `nixfmt-lambda.patch`
  Keeps common lambda/update forms such as `args // { ... }` and
  `name = arg:` more compact when they still read well.

## Usage

From the repository root:

```sh
nix fmt
```

Directly as a command after installing the package:

```sh
nixfmt path/to/file.nix
```
