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

### 2. Partition the disk (UEFI/GPT)

This setup uses three partitions: an EFI system partition, a swap partition, and a btrfs root partition with subvolumes for `/`, `/home`, and `/nix` (with zstd compression).

Swap is sized to `RAM + sqrt(RAM)` so hibernation works (kernel's recommended minimum).

```bash
DISK=/dev/nvme0n1
RAM_MIB=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)
SWAP_MIB=$(awk -v r="$RAM_MIB" 'BEGIN {print int(r + sqrt(r) + 1)}')
ESP_END=512
SWAP_END=$((ESP_END + SWAP_MIB))

parted "$DISK" -- mklabel gpt
parted "$DISK" -- mkpart ESP fat32 1MiB ${ESP_END}MiB
parted "$DISK" -- set 1 esp on
parted "$DISK" -- mkpart primary linux-swap ${ESP_END}MiB ${SWAP_END}MiB
parted "$DISK" -- mkpart primary btrfs ${SWAP_END}MiB 100%
```

This creates:

| Partition   | Size                   | Type  | Purpose              |
|-------------|------------------------|-------|----------------------|
| `/dev/nvme0n1p1` | 512 MiB                | FAT32 | EFI System Partition |
| `/dev/nvme0n1p2` | RAM + sqrt(RAM) MiB    | swap  | Swap (hibernate-ok)  |
| `/dev/nvme0n1p3` | Rest of disk           | btrfs | Root filesystem      |

### 3. Format the partitions

```bash
mkfs.fat -F 32 -n boot /dev/nvme0n1p1
mkswap -L swap /dev/nvme0n1p2
mkfs.btrfs -L nixos /dev/nvme0n1p3
```

### 4. Create btrfs subvolumes

```bash
mount /dev/disk/by-label/nixos /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
umount /mnt
```

### 5. Mount the filesystems

```bash
MOPTS="compress=zstd:3,noatime,ssd"
mount -o subvol=@,$MOPTS /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/{boot,home,nix}
mount -o subvol=@home,$MOPTS /dev/disk/by-label/nixos /mnt/home
mount -o subvol=@nix,$MOPTS /dev/disk/by-label/nixos /mnt/nix
mount /dev/disk/by-label/boot /mnt/boot
swapon /dev/disk/by-label/swap
```

### 6. Generate the hardware configuration

```bash
nixos-generate-config --root /mnt
```

This creates `/mnt/etc/nixos/hardware-configuration.nix`, which contains UUIDs specific to this disk and must be committed into the repo before installing.

### 7. Send hardware-configuration.nix to another machine

The live ISO has no git checkout, so push the file to [paste.rs](https://paste.rs) and grab it from your daily-driver machine:

```bash
curl --data-binary @/mnt/etc/nixos/hardware-configuration.nix https://paste.rs
```

paste.rs prints back a URL like `https://paste.rs/abc.nix`. Keep it.

### 8. Add the new host in the dotfiles repo

On another machine with this repo checked out:

```bash
HOST=<hostname>
mkdir -p hosts/$HOST
curl https://paste.rs/abc.nix > hosts/$HOST/hardware-configuration.nix
cp hosts/t440p/configuration.nix hosts/$HOST/configuration.nix  # start from an existing host
```

Register the host in `flake.nix` under `nixosConfigurations`:

```nix
<hostname> = mkHost "<hostname>" {
  isLaptop = true;           # or false
  primaryMonitors = [ ... ]; # optional
};
```

Commit and push to master:

```bash
git add hosts/$HOST flake.nix
git commit -m "feat: add $HOST host"
git push
```

### 9. Install from GitHub

Back on the NixOS USB:

```bash
nixos-install --flake github:peteyycz/dotfiles#<hostname>
```

You will be prompted to set the root password.

### 10. Reboot

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
sudo nixos-rebuild switch --flake /path/to/nixos-config#<hostname>
```

