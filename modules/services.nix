{ ... }:
{
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;  # key-only
  };

  services.printing.enable = false;

  hardware.bluetooth.enable = true;

  services.linuxMagicForce.enable = true;
}
