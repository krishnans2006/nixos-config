#!/usr/bin/env bash

set -e

if [[ $# -ne 1 ]]; then
  echo "Usage: ./scripts/install-home-only.sh <home-configuration>" >&2
  exit 2
fi

SYSTEM="$1"
FLAKE="path:$(pwd -P)"

set -x

NIX_USER_CHROOT_VERSION="2.1.1"
NIX_USER_CHROOT_URL="https://github.com/nix-community/nix-user-chroot/releases/download/${NIX_USER_CHROOT_VERSION}/nix-user-chroot-bin-${NIX_USER_CHROOT_VERSION}-$(uname -m)-unknown-linux-musl"

BIN_DIR="${HOME}/.local/bin"
NIX_ROOT="${HOME}/.nix"
NIX_USER_CHROOT="${BIN_DIR}/nix-user-chroot"

echo "Initializing the public dotfiles submodule..."
git submodule update --init --recursive -- dotfiles

mkdir -p "${BIN_DIR}"

if [[ ! -x "${NIX_USER_CHROOT}" ]]; then
  echo "Installing nix-user-chroot ${NIX_USER_CHROOT_VERSION}..."
  curl --fail --location --retry 3 \
    --output "${NIX_USER_CHROOT}" \
    "${NIX_USER_CHROOT_URL}"
  chmod 0755 "${NIX_USER_CHROOT}"
fi

mkdir -p "${NIX_ROOT}"
chmod 0755 "${NIX_ROOT}"

if [[ ! -d "${NIX_ROOT}/store" ]]; then
  echo "Installing Nix in ${NIX_ROOT}..."
  "${NIX_USER_CHROOT}" "${NIX_ROOT}" bash -c \
    'set -exo pipefail; curl --fail --location --retry 3 https://nixos.org/nix/install | sh -s -- --no-daemon'
fi

NIX_CONFIG_FILE="${NIX_ROOT}/etc/nix/nix.conf"
mkdir -p "${NIX_ROOT}/etc/nix"
touch "${NIX_CONFIG_FILE}"

if ! grep -Fxq 'extra-experimental-features = nix-command flakes' "${NIX_CONFIG_FILE}"; then
  printf '\nextra-experimental-features = nix-command flakes\n' >> "${NIX_CONFIG_FILE}"
fi

if ! grep -Fxq 'accept-flake-config = true' "${NIX_CONFIG_FILE}"; then
  printf 'accept-flake-config = true\n' >> "${NIX_CONFIG_FILE}"
fi

echo "Building and activating ${SYSTEM}..."
backup_extension="hm-backup-$(date +%Y%m%d%H%M%S)"
"${NIX_USER_CHROOT}" "${NIX_ROOT}" bash -c '
  set -ex
  . "${HOME}/.nix-profile/etc/profile.d/nix.sh"
  generation="$(nix build \
    --no-link \
    --print-out-paths \
    "${1}#homeConfigurations.${2}.activationPackage")"
  HOME_MANAGER_BACKUP_EXT="${3}" "${generation}/activate"
' bash "${FLAKE}" "${SYSTEM}" "${backup_extension}"

echo
echo "${SYSTEM} installed successfully."
echo "Reconnect, or run ${BIN_DIR}/home-only-shell now."
