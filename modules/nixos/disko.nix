{ inputs, ... }:
{
  flake.modules.nixos.disko =
    { config, lib, ... }:
    let
      cfg = config.peteyycz.disk;
      btrfsMountOptions = [
        "compress=zstd:3"
        "noatime"
        "ssd"
      ];
    in
    {
      imports = [ inputs.disko.nixosModules.disko ];

      options.peteyycz.disk = {
        device = lib.mkOption {
          type = lib.types.str;
          example = "/dev/nvme0n1";
          description = ''
            Whole-disk device to partition. No default so a missing value
            fails loudly at eval rather than silently nuking the wrong disk.
          '';
        };
        swapSizeMiB = lib.mkOption {
          type = lib.types.ints.positive;
          example = 16512;
          description = ''
            Swap LV size in MiB. Set per host to RAM_MiB + ceil(sqrt(RAM_MiB))
            so hibernation has the kernel-recommended minimum headroom.
          '';
        };
        bootMaskMode = lib.mkOption {
          type = lib.types.strMatching "0[0-7]{3}";
          default = "0077";
          description = ''
            Octal mask for fmask=/dmask= mount options on the FAT32 ESP.
            "0077" is root-only and the safer default; "0022" makes /boot
            world-readable.
          '';
        };
      };

      config = {
        disko.devices = {
          disk.main = {
            device = cfg.device;
            type = "disk";
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  priority = 1;
                  size = "512M";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [
                      "fmask=${cfg.bootMaskMode}"
                      "dmask=${cfg.bootMaskMode}"
                    ];
                  };
                };
                luks = {
                  size = "100%";
                  label = "luks";
                  content = {
                    type = "luks";
                    name = "cryptroot";
                    extraFormatArgs = [ "--type luks2" ];
                    settings.allowDiscards = true;
                    content = {
                      type = "lvm_pv";
                      vg = "main";
                    };
                  };
                };
              };
            };
          };

          lvm_vg.main = {
            type = "lvm_vg";
            lvs = {
              swap = {
                size = "${toString cfg.swapSizeMiB}M";
                content = {
                  type = "swap";
                  resumeDevice = true;
                };
              };
              root = {
                size = "100%FREE";
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-L"
                    "nixos"
                    "-f"
                  ];
                  subvolumes = {
                    "@" = {
                      mountpoint = "/";
                      mountOptions = btrfsMountOptions;
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = btrfsMountOptions;
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = btrfsMountOptions;
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
}
