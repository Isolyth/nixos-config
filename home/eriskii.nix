{ inputs, pkgs, ... }:
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    ./modules/hyprland.nix
    ./modules/niri.nix
    ./modules/kitty.nix
    ./modules/firefox.nix
    ./modules/xdg.nix
    ./modules/theming.nix
    ./modules/clipboard.nix
    ./modules/claude-code.nix
    ./modules/git.nix
    ./modules/zsh.nix
    ./modules/vscode.nix
    ./modules/matugen.nix
    ./modules/obsidian.nix
    ./modules/idle.nix
    ./modules/btop.nix
  ];

  home.username = "eriskii";
  home.homeDirectory = "/home/eriskii";
  home.stateVersion = "25.11";   # don't bump

  home.sessionVariables = {
    TERMINAL = "kitty";
  };

  # home-manager uses `useUserPackages`, which redirects xdg-desktop-portal's
  # search path to the per-user profile. System-level `xdg.portal.extraPortals`
  # therefore isn't scanned — install gtk portal to the user profile too so
  # libadwaita apps (incl. flatpaks) get the Settings interface for color-scheme.
  home.packages = [ pkgs.xdg-desktop-portal-gtk ];

  programs.home-manager.enable = true;

  # Dank Material Shell (Quickshell-based desktop shell)
  # Settings are sourced from ./dms/settings.json — to update from a UI session,
  # `cp ~/.config/DankMaterialShell/settings.json ~/nixos-config/home/dms/` and rebuild.
  programs.dank-material-shell = {
    enable = true;
    systemd.enable = true;
    settings = builtins.fromJSON (builtins.readFile ./dms/settings.json);
    session = builtins.fromJSON (builtins.readFile ./dms/session.json);
  };
}
