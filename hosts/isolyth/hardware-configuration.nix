# PLACEHOLDER — overwrite this from the live installer with:
#   nixos-generate-config --root /mnt --no-filesystems --dir /tmp/hwgen
#   cp /tmp/hwgen/hardware-configuration.nix ./hosts/isolyth/hardware-configuration.nix
#
# --no-filesystems is important: disko owns the filesystem definitions, the
# hardware file should only contain hardware/kernel-module detections.
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
