# NixOS Configuration — ThinkPad T440p

This repository contains a reproducible [NixOS](https://nixos.org/) configuration for a ThinkPad T440p using flakes.

## Installation

Based on the [NixOS manual](https://nixos.org/manual/nixos/stable/#sec-installation).

### 1. Boot the installer

Download the NixOS minimal ISO from [nixos.org/download](https://nixos.org/download/) and write it to a USB drive:

```bash
dd if=nixos-minimal-*-x86_64-linux.iso of=/dev/sdX bs=4M status=progress
```

Boot from the USB stick. You will be logged in as root automatically.

If you need Wi-Fi:

```bash
sudo systemctl start wpa_supplicant
wpa_cli
> add_network
> set_network 0 ssid "YOUR_SSID"
> set_network 0 psk "YOUR_PASSWORD"
> enable_network 0
> quit
```

### 2. Partition the disk (UEFI/GPT)

This setup uses three partitions: an EFI system partition, a swap partition, and an ext4 root partition.

Replace `/dev/sda` with your actual disk (e.g. `/dev/nvme0n1`).

```bash
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MB 512MB
parted /dev/sda -- set 1 esp on
parted /dev/sda -- mkpart primary linux-swap 512MB 8GB
parted /dev/sda -- mkpart primary ext4 8GB 100%
```

This creates:

| Partition   | Size          | Type  | Purpose              |
|-------------|---------------|-------|----------------------|
| `/dev/sda1` | 512 MB        | FAT32 | EFI System Partition |
| `/dev/sda2` | ~7.5 GB       | swap  | Swap                 |
| `/dev/sda3` | Rest of disk  | ext4  | Root filesystem      |

### 3. Format the partitions

```bash
mkfs.fat -F 32 -n boot /dev/sda1
mkswap -L swap /dev/sda2
mkfs.ext4 -L nixos /dev/sda3
```

### 4. Mount the filesystems

```bash
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
swapon /dev/disk/by-label/swap
```

### 5. Generate the initial configuration

```bash
nixos-generate-config --root /mnt
```

This creates `/mnt/etc/nixos/configuration.nix` and `/mnt/etc/nixos/hardware-configuration.nix`.

### 6. Apply this configuration

Instead of editing the generated config, clone this repo and use it directly:

```bash
nix-env -iA nixos.git
git clone https://github.com/peteyycz/nixos-config.git /mnt/etc/nixos-config
```

Keep the generated `hardware-configuration.nix` — it contains UUIDs specific to your disk. Copy it into the repo:

```bash
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos-config/hosts/t440p/hardware-configuration.nix
```

### 7. Install

```bash
nixos-install --flake /mnt/etc/nixos-config#t440p
```

You will be prompted to set the root password.

### 8. Reboot

```bash
reboot
```

After rebooting, set a password for your user:

```bash
sudo passwd peteyycz
```

## Rebuilding after changes

After making changes to the configuration, rebuild with:

```bash
sudo nixos-rebuild switch --flake /path/to/nixos-config#t440p
```

## Repository structure

```
.
├── flake.nix                          # Flake entry point
├── flake.lock                         # Pinned dependencies
└── hosts/
    └── t440p/
        ├── configuration.nix          # System configuration
        └── hardware-configuration.nix # Hardware-specific config (machine-generated)
```
