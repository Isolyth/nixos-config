{ pkgs, ... }:
{
  # Declarative flatpak via nix-flatpak. Module sets up the Flathub remote by
  # default; we just declare packages + per-app overrides.
  services.flatpak = {
    enable = true;
    update.onActivation = true;

    packages = [
      "com.jeffser.Nocturne"
    ];

    overrides = {
      # Let Nocturne (libadwaita) read the matugen-generated gtk.css so it
      # picks up the DMS palette. /nix/store:ro is needed because home-manager
      # keeps gtk.css as a symlink into the nix store; without store access the
      # sandbox can't resolve it.
      "com.jeffser.Nocturne".Context.filesystems = [
        "xdg-config/gtk-4.0:ro"
        "/nix/store:ro"
      ];
    };
  };

  # gtk portal for file pickers / appearance settings inside libadwaita flatpaks.
  # hyprland portal is already pulled in by programs.hyprland.
  xdg.portal = {
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

    # hyprland portal only implements Screenshot/ScreenCast/GlobalShortcuts.
    # Route the rest (Settings, FileChooser, etc.) to gtk so libadwaita apps
    # actually see `color-scheme = prefer-dark` from dconf.
    config.hyprland = {
      default = [ "hyprland" "gtk" ];
      "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
    };
  };
}
