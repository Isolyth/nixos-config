{ pkgs, ... }:
{
  # System-level Qt platform integration
  # NB: NixOS qt module only accepts legacy enum values; "qt5ct" actually
  # configures the env vars correctly for BOTH qt5ct and qt6ct.
  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "kvantum";
  };

  # dconf is required for gsettings to work (which Thunar / GTK apps use)
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    # kdePackages.qt6ct is the qt6ct-kde fork (KDE color scheme support)
    kdePackages.qt6ct
    libsForQt5.qt5ct
    kdePackages.qtstyleplugin-kvantum
    libsForQt5.qtstyleplugin-kvantum
    glib                          # for gsettings command
    gsettings-desktop-schemas
  ];
}
