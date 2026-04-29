{ pkgs, ... }:
{
  # System services that DMS / Quickshell expect to be present
  services.accounts-daemon.enable = true;
  services.power-profiles-daemon.enable = true;

  # cups-pk-helper provides the PolKit interface DMS uses to query printer state.
  # We don't need full printing, just the helper.
  services.printing.enable = false;
  environment.systemPackages = with pkgs; [ cups-pk-helper ];

  # Polkit (DMS uses it for privileged actions like reboot/shutdown via the menu)
  security.polkit.enable = true;

  # gnome-keyring, used by dms for secret storage and xwayland/sso
  services.gnome.gnome-keyring.enable = true;
}
