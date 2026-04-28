{ ... }:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # No display manager / greeter — login at tty, exec Hyprland from shell rc.
  # Add to your ~/.zprofile (or ~/.bash_profile) on first boot:
  #   if [ -z "$DISPLAY" ] && [ "$(tty)" = /dev/tty1 ]; then exec Hyprland; fi

  # Wayland-friendly env vars (NVIDIA in particular needs these)
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # XDG portals for screen sharing / file pickers under Wayland
  xdg.portal = {
    enable = true;
    extraPortals = [ ];   # hyprland module already includes hyprland portal
  };
}
