# NixOS Configuration

This repository contains a reproducible [NixOS](https://nixos.org/) configuration using flakes.

## Installation

Based on the [NixOS manual](https://nixos.org/manual/nixos/stable/#sec-installation).

### 1. Boot the installer

Download the NixOS minimal ISO from [nixos.org/download](https://nixos.org/download/) and write it to a USB drive:

```bash
dd if=nixos-minimal-*-x86_64-linux.iso of=/dev/sdX bs=4M status=progress
```

Boot from the USB stick. You will be logged in as root automatically.

### 2. Add the new host in the dotfiles repo

The on-disk layout is declared in `modules/nixos/disko.nix` and the LUKS+TPM2 unlock and hibernation in their own modules. New hosts opt in by importing them and setting two values:

```
/dev/<disk>
├── p1  ESP    512 MiB FAT32                       → /boot
└── p2  LUKS   rest of disk
    └── LVM VG "main"
        ├── lv "swap"  RAM + sqrt(RAM) MiB          (encrypted, hibernate-ok)
        └── lv "root"  100%FREE  btrfs              → @ / @home / @nix
                                                      (compress=zstd:3, noatime, ssd)
```

On a machine with this repo checked out, copy an existing host as a starting point:

```bash
HOST=<hostname>
cp -r modules/hosts/t14g2 modules/hosts/$HOST
```

Boot the live ISO on the target machine and dump its detected hardware so you can pick the right `boot.initrd.availableKernelModules` / `boot.kernelModules` / CPU-microcode lines for the new host. The simplest way is to push it to a paste service:

```bash
nixos-generate-config --no-filesystems --root /tmp/scan
curl --data-binary @/tmp/scan/etc/nixos/hardware-configuration.nix https://paste.rs
```

Edit `modules/hosts/$HOST/hardware.nix` accordingly. Disko owns the filesystem layout, so the file should contain only kernel modules, CPU/microcode, and `nixpkgs.hostPlatform` — **no `fileSystems` and no `swapDevices` blocks**.

Edit `modules/hosts/$HOST/default.nix` so the imports include the new modules:

```nix
imports = [
  nixos.${HOST}-hardware
  nixos.${HOST}-configuration
  nixos.common
  nixos.disko
  nixos.secureboot
  nixos.luks-tpm2
  nixos.hibernation
  # nixos.laptop / nixos.fingerprint / nixos.u2f / nixos.gaming as appropriate
];
```

In `modules/hosts/$HOST/configuration.nix`, set the per-host disk values:

```nix
peteyycz.disk = {
  device = "/dev/nvme0n1";        # whole disk to wipe
  swapSizeMiB = 16512;             # RAM_MiB + ceil(sqrt(RAM_MiB))
  bootMaskMode = "0022";           # or "0077"
};
```

Compute `swapSizeMiB` from RAM:

```bash
awk '/MemTotal/ {r=int($2/1024); printf "%d\n", r + int(sqrt(r) + 0.999)}' /proc/meminfo
```

Commit and push to master before installing.

### 3. Partition and install via disko

Back on the NixOS USB, partition the disk:

```bash
sudo nix --experimental-features 'nix-command flakes' run \
    github:nix-community/disko/latest -- \
    --mode destroy,format,mount \
    --flake github:peteyycz/dotfiles#<hostname>
```

`disko --mode destroy,format,mount` wipes the disk, creates the GPT layout, opens LUKS (you will set the passphrase here), creates the LVM volumes, formats btrfs, and mounts everything under `/mnt`.

Before installing, generate Secure Boot keys into the new system so lanzaboote has something to sign with on first boot:

```bash
sudo mkdir -p /mnt/var/lib/sbctl
sudo mount --bind /mnt/var/lib/sbctl /var/lib/sbctl
sudo nix --experimental-features 'nix-command flakes' run \
    nixpkgs#sbctl -- create-keys
sudo umount /var/lib/sbctl
```

The bind mount redirects sbctl's hard-coded `/var/lib/sbctl` path into the target filesystem, so the keys land where the installed system will look for them. Now install:

```bash
sudo nixos-install --no-root-passwd --flake github:peteyycz/dotfiles#<hostname>
```

`nixos-install` writes the system and lanzaboote signs the bootloader, kernel, and initrd with the keys you just generated.

### 4. Reboot and set passwords

```bash
reboot
```

Boot will prompt for the LUKS passphrase. After login:

```bash
sudo passwd peteyycz
```

### 5. Enable Secure Boot and enroll TPM2 for unattended boot

The `secureboot` module replaces systemd-boot with [lanzaboote](https://github.com/nix-community/lanzaboote) so the bootloader, kernel, and initrd are all signed. Binding the LUKS TPM2 keyslot to PCR 7 (Secure Boot policy) then gives a stable measurement that survives firmware updates — but is only meaningful once Secure Boot is actually enforcing.

First confirm the firmware is in **Setup Mode** (no Platform Key enrolled yet — required so `sbctl enroll-keys` can adopt your generated keys):

```bash
bootctl status | grep -i 'secure boot'   # → "disabled (setup)"
```

If it instead reports `enabled` or `disabled` without `(setup)`, reboot into firmware and clear/reset the Secure Boot keys. On Lenovo: Security → Secure Boot → Reset to Setup Mode.

Enroll the keys generated during step 3 and verify everything in `/boot` is signed:

```bash
sudo sbctl enroll-keys --microsoft   # keep MS keys so option ROMs still verify
sudo sbctl verify                    # all listed files should report "signed"
```

Reboot into firmware setup, **enable Secure Boot**, and boot back in. Verify:

```bash
bootctl status | grep -i 'secure boot'   # → "enabled (user)"
```

Now enroll the TPM2 keyslot bound to PCR 7. The LUKS partition is the second partition created by disko (`/dev/<disk>p2`):

```bash
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p2
```

Reboot — LUKS now unlocks unattended via TPM2. PCR 7 only changes when Secure Boot keys or policy change, so firmware updates and kernel upgrades won't break the unlock.

**Re-enrolling later.** If PCR 7 changes (you toggled Secure Boot, re-enrolled keys, etc.), drop back to the passphrase at boot, then check the LUKS header before doing anything destructive:

```bash
sudo cryptsetup luksDump /dev/nvme0n1p2
```

Note the keyslot index of the existing TPM2 token (look for `systemd-tpm2` in the Tokens section), then wipe **that specific slot number** and re-enroll:

```bash
sudo cryptsetup luksKillSlot /dev/nvme0n1p2 <N>
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p2
```

Avoid `systemd-cryptenroll --wipe-slot=tpm2` — its targeting can drift if tokens are stale, and a mistake there will wipe your passphrase keyslot too. Always pass an explicit slot number.

### 6. Enroll fingerprint (laptops with a reader)

```bash
sudo fprintd-enroll
```

Fingerprint is used for sudo, hyprlock, and sddm only — not for LUKS unlock at boot (fprintd-class readers aren't supported in the initrd).

## Rebuilding after changes

After making changes to the configuration, rebuild with:

```bash
sudo nixos-rebuild switch --flake /path/to/dotfiles#<hostname>
```

