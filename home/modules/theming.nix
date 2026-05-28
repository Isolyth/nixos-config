{ pkgs, ... }:
{
  # Cursor — applies via XCURSOR_THEME, HYPRCURSOR_THEME, GTK settings, and Qt
  home.pointerCursor = {
    enable = true;
    package = pkgs.oreo-cursors-plus;
    name = "oreo_white_cursors";
    size = 28;
    gtk.enable = true;
    x11.enable = true;
    hyprcursor.enable = true;
  };

  # GTK 3/4 — DMS writes the colors via gtk.css, but we need a settings.ini
  # telling apps (Thunar, gtk apps) which named theme + icon set to use.
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";   # per DMS panel recommendation; matugen gtk.css overlays on top
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    # Silence the legacy-default deprecation warning on home.stateVersion < 26.05
    # by explicitly opting in to the same theme for GTK 4.
    gtk4.theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };

    # Import DMS's matugen-generated `@define-color` overrides into gtk-4.0/gtk.css
    # so libadwaita apps pick up the wallpaper-derived palette. Absolute file://
    # path is required because the generated gtk.css lives in /nix/store and a
    # relative URL would resolve there, not in ~/.config/gtk-4.0.
    gtk4.extraCss = ''
      @import url("file:///home/eriskii/.config/gtk-4.0/dank-colors.css");
    '';
  };

  # Qt — match system platform theme (qt6ct) so Qt apps follow our settings
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  # Make GTK env / GSettings actually work for non-GNOME apps (Thunar)
  home.sessionVariables = {
    GTK_THEME = "adw-gtk3-dark";
  };
}
