{ config, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Belt-and-braces for NVIDIA suspend reliability.
  # Tells the driver to back up VRAM to system RAM on S3, which is the
  # canonical fix for "wake gives black screen / glitched output".
  boot.kernelParams = [
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  # NVIDIA RTX 4070 SUPER (proprietary driver)
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    # Save/restore VRAM across systemd S3 suspend. Required for sleep to
    # wake correctly on NVIDIA — DOES NOT enable laptop dynamic power
    # saving (that's `finegrained`, which stays off).
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
