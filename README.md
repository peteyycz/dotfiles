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

Back on the NixOS USB, partition the disk and install in one go:

```bash
sudo nix --experimental-features 'nix-command flakes' run \
    github:nix-community/disko/latest -- \
    --mode destroy,format,mount \
    --flake github:peteyycz/dotfiles#<hostname>

sudo nixos-install --no-root-passwd --flake github:peteyycz/dotfiles#<hostname>
```

`disko --mode destroy,format,mount` wipes the disk, creates the GPT layout, opens LUKS (you will set the passphrase here), creates the LVM volumes, formats btrfs, and mounts everything under `/mnt`. `nixos-install` then writes the system.

### 4. Reboot and set passwords

```bash
reboot
```

Boot will prompt for the LUKS passphrase. After login:

```bash
sudo passwd peteyycz
```

### 5. Enroll TPM2 for unattended boot

Run once on the new machine; the LUKS partition is the second partition created by disko (`/dev/<disk>p2`):

```bash
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0,1,7 /dev/nvme0n1p2
```

Reboot — LUKS now unlocks unattended via TPM2. If a firmware update changes a measured PCR, fall back to the install passphrase and re-run the enrollment command.

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

