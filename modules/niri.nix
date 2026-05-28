{ ... }:
{
  # niri-flake nixosModule (imported at the flake level) provides `programs.niri`.
  programs.niri.enable = true;

  # No display manager / greeter — login at tty, exec niri from shell rc.
  # On first boot add to ~/.zprofile (or ~/.bash_profile):
  #   if [ -z "$DISPLAY" ] && [ "$(tty)" = /dev/tty1 ]; then exec niri-session; fi
  # (Use `Hyprland` instead of `niri-session` to launch the other compositor.)

  # Wayland session env vars are already exported by modules/hyprland.nix
  # (NIXOS_OZONE_WL, LIBVA_DRIVER_NAME, GBM_BACKEND, __GLX_VENDOR_LIBRARY_NAME,
  # XDG_SESSION_TYPE, MOZ_ENABLE_WAYLAND). They apply equally to niri, so no
  # duplication here.

  # XDG portals — niri-flake registers its own portal preferences; we only
  # need to make sure the portal stack is on.
  xdg.portal.enable = true;
}
