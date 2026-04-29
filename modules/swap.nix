{ ... }:
{
  # 32 GiB swap file on btrfs. The file itself is created by a one-time
  # script (/tmp/create-swap.sh) because btrfs swap files require a dedicated
  # NoCoW subvolume — easier to create explicitly than to do via NixOS.
  #
  # NixOS just references the existing file; if it doesn't exist on a fresh
  # install, run the create script and rebuild.
  swapDevices = [
    {
      device = "/swap/swapfile";
      priority = 10;            # higher number = preferred over zram (-2 default)
    }
  ];
}
