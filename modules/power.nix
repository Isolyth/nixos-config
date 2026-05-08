{ pkgs, ... }:
{
  # Desktop machine — no battery, no reason to throttle anything.

  # Pin CPU to max frequency.
  powerManagement.cpuFreqGovernor = "performance";

  # Disable laptop-style ACPI suspend scripts. We're not suspending; we're not
  # using the lid. The base 'powerManagement.enable' is fine to leave on (it
  # provides hibernate hooks etc) but we never trigger any of it.
  powerManagement.enable = true;

  # Disable PCIe ASPM (Active State Power Management). Desktops gain nothing
  # from it and it occasionally adds latency to NVMe / GPU traffic.
  boot.kernelParams = [ "pcie_aspm=off" ];

  # Disable USB autosuspend — peripherals are always plugged in, no need.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/autosuspend", ATTR{power/autosuspend}="-1"
  '';

  # Set power-profiles-daemon default to "performance" on boot.
  # ppd doesn't expose a "default profile" NixOS option, so we do it imperatively
  # in a one-shot service that runs after the daemon comes up.
  # Hung off graphical.target because ppd's unit is After=multi-user.target —
  # WantedBy=multi-user.target here would create an ordering cycle.
  systemd.services.set-power-profile-performance = {
    description = "Set power-profiles-daemon to performance";
    wantedBy = [ "graphical.target" ];
    after = [ "power-profiles-daemon.service" ];
    requires = [ "power-profiles-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance";
    };
  };
}
