{
  # Declarative disk layout for the install drive (nvme0n1).
  # Mirrors your Arch setup:
  #   - 1G EFI System Partition   → /boot
  #   - rest as LUKS-encrypted btrfs with subvolumes:
  #       @       → /
  #       @home   → /home
  #       @nix    → /nix      (replaces Arch's @pkg)
  #       @log    → /var/log
  #
  # When you `disko --mode disko ./disko-config.nix`, this WIPES nvme0n1.
  # Triple-check the device path matches your install target.

  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            label = "boot";
            start = "1M";
            end = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          luks = {
            size = "100%";
            label = "luks";
            content = {
              type = "luks";
              name = "cryptroot";
              # Settings comparable to a typical Arch cryptsetup luksFormat default
              settings = {
                allowDiscards = true;
                # keyFile is intentionally omitted — disko will prompt you for the passphrase
              };
              extraOpenArgs = [ "--allow-discards" ];
              content = {
                type = "btrfs";
                extraArgs = [ "-f" "-L" "nixos" ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd:3" "noatime" "ssd" "space_cache=v2" ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd:3" "noatime" "ssd" "space_cache=v2" ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd:3" "noatime" "ssd" "space_cache=v2" ];
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = [ "compress=zstd:3" "noatime" "ssd" "space_cache=v2" ];
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
