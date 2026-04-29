{ inputs, pkgs, ... }:
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    ./modules/hyprland.nix
    ./modules/kitty.nix
    ./modules/xdg.nix
    ./modules/theming.nix
    ./modules/clipboard.nix
    ./modules/claude-code.nix
  ];

  home.username = "eriskii";
  home.homeDirectory = "/home/eriskii";
  home.stateVersion = "25.11";   # don't bump

  programs.home-manager.enable = true;

  # Dank Material Shell (Quickshell-based desktop shell)
  # Settings are sourced from ./dms/settings.json — to update from a UI session,
  # `cp ~/.config/DankMaterialShell/settings.json ~/nixos-config/home/dms/` and rebuild.
  programs.dank-material-shell = {
    enable = true;
    systemd.enable = true;
    settings = builtins.fromJSON (builtins.readFile ./dms/settings.json);
  };
}
