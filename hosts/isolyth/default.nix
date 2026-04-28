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
    ../../modules/fonts.nix
    ../../modules/nix-settings.nix
    ../../modules/services.nix
    ../../modules/packages.nix
  ];

  networking.hostName = "isolyth";

  # Pin to first install version. Don't bump.
  system.stateVersion = "25.11";
}
