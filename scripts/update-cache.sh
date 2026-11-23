#!/usr/bin/env bash

set -euo pipefail

repository=$1
build_cache=$2
state=${STATE_DIRECTORY:?Run under the nix-cache-update service}
work=${RUNTIME_DIRECTORY:?Run under the nix-cache-update service}
update_ref=refs/heads/auto-update

git clone --branch main --recurse-submodules -- "$repository" "$work/checkout"
cd -- "$work/checkout"
main_revision=$(git rev-parse HEAD)
previous_update=$(git rev-parse --verify --quiet refs/remotes/origin/auto-update || true)

# Nix registers each result link by its absolute path. Only the current alias moves.
roots=$(mktemp -d -- "$state/run.XXXXXXXX")
trap 'rm -rf -- "$roots"' EXIT

export NIX_CACHE_CHECKOUT="$PWD"
echo "Building main at $main_revision"
NIX_CACHE_ROOTS="$roots/main" bash "$build_cache" --no-update-lock-file --diff never

nix flake update
git switch -c auto-update
git add -- flake.lock
if ! git diff --cached --quiet; then
  git -c user.name="Nix Cache" -c user.email=nixcache@krishy.dev \
    commit --no-gpg-sign -m "Update flake"
fi

update_revision=$(git rev-parse HEAD)
echo "Building auto-update at $update_revision"
NIX_CACHE_ROOTS="$roots/auto-update" bash "$build_cache" --no-update-lock-file --diff never

echo "Verifying both closures through Harmonia"
readlink -e -- "$roots/main/"* "$roots/auto-update/"* |
  nix store verify --quiet --recursive --no-contents --store https://nixcache.krishy.dev \
    --option narinfo-cache-positive-ttl 0 --option narinfo-cache-negative-ttl 0 --stdin

remote_main=$(git ls-remote --exit-code --refs origin refs/heads/main)
if [[ "$remote_main" != "$main_revision"$'\t'refs/heads/main ]]; then
  echo "main advanced during the build; skipping publication" >&2
  exit 1
fi

ln -s -- "$roots" "$roots/current"
# A failed push can have reached GitHub. Keep these roots until the next successful run.
trap - EXIT
git push --force-with-lease="$update_ref:$previous_update" origin "HEAD:$update_ref"

mv -Tf -- "$roots/current" "$state/current"
for old_roots in "$state"/run.*; do
  if [[ "$old_roots" != "$roots" ]]; then
    rm -rf -- "$old_roots"
  fi
done

echo "Published auto-update at $update_revision; collecting unrooted store paths"
nix store gc --quiet
