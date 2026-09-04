{ ... }:
{
  boot.kernelModules = [ "hid_magicmouse" ];

  # Let the logged-in user talk to keyboard raw-HID interfaces so WebHID
  # configurators (VIA / Vial / NuPhy Console) can see the board in Chrome.
  # By default every /dev/hidraw* is root:0600, so the browser can't open it.
  # uaccess grants the active-seat user access via logind ACLs; the group/mode
  # fallback covers non-logind sessions. Scoped to the NuPhy Air75 V2 (19f5:3245).
  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="19f5", MODE="0660", GROUP="users", TAG+="uaccess"
  '';
}
