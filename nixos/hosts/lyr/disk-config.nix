{ inputs, ... }:
let
  # FORESEE 512GB SSD — fast tier + boot
  ssdDevice = "/dev/disk/by-id/ata-FORESEE_512GB_SSD_PEJ242Q043461";
  # HGST 1TB HDD — bulk storage tier
  hddDevice = "/dev/disk/by-id/ata-HGST_HTS721010A9E630_JR1000BDGR9AJE";
in
{
  imports = [
    inputs.disko.nixosModules.disko
  ];

  boot.supportedFilesystems = [ "bcachefs" ];

  disko.devices = {
    disk = {
      # SSD — fast tier for metadata + caching + boot
      ssd = {
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
            main = {
              size = "100%";
              content = {
                type = "bcachefs";
                filesystem = "main_bcachefs";
                label = "ssd.fast";
                extraFormatArgs = [ "--discard" ];
              };
            };
          };
        };
      };

      # HDD — bulk storage tier
      hdd = {
        type = "disk";
        device = hddDevice;
        content = {
          type = "gpt";
          partitions = {
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
    };

    bcachefs_filesystems = {
      main_bcachefs = {
        type = "bcachefs_filesystem";
        extraFormatArgs = [
          "--compression=lz4"
          "--background_compression=zstd:6"
          "--background_target=hdd"
          "--foreground_target=ssd"
          "--promote_target=ssd"
          "--metadata_target=ssd"
        ];
        subvolumes = {
          "@root" = {
            mountpoint = "/";
            mountOptions = [ "noatime" ];
          };
          "@nix" = {
            mountpoint = "/nix";
            mountOptions = [ "noatime" ];
          };
          "@home" = {
            mountpoint = "/home";
            mountOptions = [ "noatime" ];
          };
          "@backups" = {
            mountpoint = "/var/backups";
            mountOptions = [ "noatime" ];
          };
          "@containers" = {
            mountpoint = "/var/lib/nixos-containers";
            mountOptions = [ "noatime" ];
          };
        };
      };
    };
  };
}
