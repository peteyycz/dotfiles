#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
    echo "usage: $0 <hostname> [<commit-sha>]" >&2
    exit 2
fi

HOST=$1
REV=${2:-master}
FLAKE="github:peteyycz/dotfiles/${REV}#${HOST}"
NIX="nix --extra-experimental-features nix-command --extra-experimental-features flakes"

cat <<EOF
About to install NixOS:
  host:  ${HOST}
  flake: ${FLAKE}

This will WIPE the target disk declared in modules/hosts/${HOST}/configuration.nix.
EOF

read -r -p "Type the hostname to confirm: " CONFIRM </dev/tty
if [ "$CONFIRM" != "$HOST" ]; then
    echo "aborted" >&2
    exit 1
fi

sudo $NIX run github:nix-community/disko/latest -- \
    --mode destroy,format,mount \
    --yes-wipe-all-disks \
    --flake "$FLAKE" </dev/tty

sudo mkdir -p /mnt/var/lib/sbctl
sudo mount --bind /mnt/var/lib/sbctl /var/lib/sbctl
sudo $NIX run nixpkgs#sbctl -- create-keys
sudo umount /var/lib/sbctl

sudo nixos-install --no-root-passwd --flake "$FLAKE"

cat <<EOF

Done. After reboot:
  - log in as your user (initialHashedPassword applies on first boot)
  - put firmware in Setup Mode, then: sudo sbctl enroll-keys --microsoft
  - reboot into firmware and ENABLE Secure Boot
  - bootctl status   # confirm "Secure Boot: enabled (user)"
  - sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/<luks-partition>
  - sudo fprintd-enroll   # if the host has a reader
EOF
