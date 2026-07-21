{ inputs, ... }:
let
  ssdDevice = "/dev/disk/by-id/nvme-SAMSUNG_MZVLB256HAHQ-000H1_S425NX2M363531";
  hddDevice = "/dev/disk/by-id/ata-ST2000DM008-2UB102_ZK20P7NY";
  wdDevice = "/dev/disk/by-id/ata-WDC_WD10EARS-00Y5B1_WD-WCAV5S128768";
in
{
  imports = [
    inputs.disko.nixosModules.disko
  ];

  boot.supportedFilesystems = [ "bcachefs" ];

  disko.devices = {
    disk = {
      # NVMe SSD - Fast tier for metadata and caching
      nvme = {
        type = "disk";
        device = ssdDevice;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            # NVMe partition for bcachefs (fast tier)
            main = {
              size = "100%";
              content = {
                type = "bcachefs";
                filesystem = "main_bcachefs";
                label = "ssd.nvme";
                extraFormatArgs = [ "--discard" ];
              };
            };
          };
        };
      };

      # HDD - Bulk storage tier
      hdd = {
        type = "disk";
        device = hddDevice;
        content = {
          type = "gpt";
          partitions = {
            # HDD partition for bcachefs (storage tier)
            main = {
              size = "100%";
              content = {
                type = "bcachefs";
                filesystem = "main_bcachefs";
                label = "hdd.storage";
              };
            };
          };
        };
      };

      # Western Digital HDD - Separate btrfs filesystem
      WD10EARS = {
        type = "disk";
        device = wdDevice;
        content = {
          type = "gpt";
          partitions = {
            main = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/mnt/wd10ears";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };

    bcachefs_filesystems = {
      main_bcachefs = {
        type = "bcachefs_filesystem";
        extraFormatArgs = [
          "--compression=lz4"
          "--background_compression=zstd:6"
          # Tiering configuration
          "--background_target=hdd"
          "--foreground_target=ssd"
          "--promote_target=ssd"
          "--metadata_target=ssd"
        ];
        # Nessun subvolume - filesystem semplice
        mountpoint = "/";
        mountOptions = [
          "noatime"
        ];
      };
    };
  };

}
