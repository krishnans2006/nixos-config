#!/usr/bin/env bash

set -e

cd -- "${NIX_CACHE_CHECKOUT:-$(dirname -- "${BASH_SOURCE[0]}")/..}"

roots="${NIX_CACHE_ROOTS:-$HOME/.local/state/nix-cache-roots}"
mkdir -p -- "$roots"

# Keep the result links so Nix GC preserves the closures Harmonia serves.
for host in mew lap pc vivo; do
  nh os build . -H "krishnan-$host" -o "$roots/$host" "$@"
  test -L "$roots/$host"
done

for host in ews janux; do
  nh home build . -c "krishnan-$host" -o "$roots/$host" "$@"
  test -L "$roots/$host"
done
