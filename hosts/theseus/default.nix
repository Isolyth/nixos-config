{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/boot.nix
    ../../modules/networking.nix
    ../../modules/locale.nix
    ../../modules/users.nix
    ../../modules/audio.nix
    ../../modules/graphics.nix
    ../../modules/hyprland.nix
    ../../modules/niri.nix
    ../../modules/fonts.nix
    ../../modules/nix-settings.nix
    ../../modules/services.nix
    ../../modules/desktop-services.nix
    ../../modules/input.nix
    ../../modules/thunar.nix
    ../../modules/qt.nix
    ../../modules/power.nix
    ../../modules/swap.nix
    ../../modules/packages.nix
    ../../modules/llama-cpp.nix
    ../../modules/flatpak.nix
    ../../modules/home-manager.nix
  ];

  networking.hostName = "theseus";

  # Pin to first install version. Don't bump.
  system.stateVersion = "25.11";
}
