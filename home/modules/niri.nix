{ config, ... }:
{
  # niri home-manager module is auto-injected by niri-flake's nixosModule
  # (via home-manager.sharedModules), so no explicit import is needed.

  programs.niri.settings = {
    # ── Monitors ──
    # Match by EDID description (make / model / serial), not connector name —
    # DRM connector indices shift between boots on this box.
    outputs."Lenovo Group Limited L24q-20 U5P0MPCL" = {
      mode = { width = 2560; height = 1440; refresh = 59.95; };
      position = { x = 0; y = 0; };
      scale = 1.0;
    };
    outputs."Guangxi Century Innovation Display Electronics Co. Ltd 27M2V 0000000000000" = {
      mode = { width = 3840; height = 2160; refresh = 144.0; };
      position = { x = 2560; y = 0; };
      scale = 1.5;
    };

    # ── Input ──
    input = {
      keyboard.xkb.layout = "us";
      mouse.accel-speed = 0.3;
      focus-follows-mouse.enable = true;
      touchpad = {
        tap = true;
        natural-scroll = true;
        click-method = "clickfinger";
        dwt = false;            # disable-while-typing
        scroll-factor = 0.3;
      };
    };

    # ── Cursor ──
    cursor = {
      theme = "oreo_white_cursors";
      size = 28;
    };

    environment = {
      XCURSOR_THEME = "oreo_white_cursors";
      XCURSOR_SIZE = "28";
      HYPRCURSOR_THEME = "oreo_white_cursors";
      HYPRCURSOR_SIZE = "28";
    };

    # ── Layout ──
    layout = {
      gaps = 5;
      border = {
        enable = true;
        width = 2;
        active.color = "rgba(193,193,255,1)";
        inactive.color = "rgba(145,145,145,0.67)";
      };
      focus-ring.enable = false;
      preset-column-widths = [
        { proportion = 1.0 / 3.0; }
        { proportion = 1.0 / 2.0; }
        { proportion = 2.0 / 3.0; }
      ];
      default-column-width = { proportion = 1.0 / 2.0; };
    };

    prefer-no-csd = true;

    # ── Autostart ──
    # DMS is started by its systemd user service via graphical-session.target;
    # don't double-launch it here.
    spawn-at-startup = [
      { command = [ "gnome-keyring-daemon" "--start" "--components=secrets" ]; }
      { command = [ "gsettings" "set" "org.gnome.desktop.interface" "cursor-theme" "oreo_white_cursors" ]; }
      { command = [ "gsettings" "set" "org.gnome.desktop.interface" "color-scheme" "prefer-dark" ]; }
      { command = [ "gsettings" "set" "org.gnome.desktop.interface" "gtk-theme" "Adwaita-dark" ]; }
      { command = [ "systemctl" "--user" "enable" "--now" "hyprpolkitagent.service" ]; }
    ];

    # ── Keybinds ──
    binds = with config.lib.niri.actions; {
      "Mod+Space".action = spawn "dms" "ipc" "call" "spotlight" "toggle";
      "Mod+Q".action = spawn "kitty";
      "Mod+C".action = close-window;
      "Mod+V".action = toggle-window-floating;
      "Mod+E".action = spawn "thunar";
      "Mod+T".action = spawn "kitty" "btop";
      "Mod+S".action = spawn "hyprshot" "--freeze" "-m" "region";
      "Mod+L".action = spawn "hyprlock";
      "Mod+Shift+F".action = fullscreen-window;
      "Mod+Escape".action = spawn "dms" "ipc" "call" "powermenu" "toggle";
      "Mod+Shift+C".action = spawn "hyprpicker" "-a";
      "Mod+Shift+W".action = spawn "dms" "ipc" "call" "settings" "toggle";

      # Move focus (column = horizontal, window = vertical inside column)
      "Mod+Left".action  = focus-column-left;
      "Mod+Right".action = focus-column-right;
      "Mod+Up".action    = focus-window-up;
      "Mod+Down".action  = focus-window-down;

      # Move windows
      "Mod+Shift+Left".action  = move-column-left;
      "Mod+Shift+Right".action = move-column-right;
      "Mod+Shift+Up".action    = move-window-up;
      "Mod+Shift+Down".action  = move-window-down;

      # Workspaces 1–10
      "Mod+1".action = focus-workspace 1;
      "Mod+2".action = focus-workspace 2;
      "Mod+3".action = focus-workspace 3;
      "Mod+4".action = focus-workspace 4;
      "Mod+5".action = focus-workspace 5;
      "Mod+6".action = focus-workspace 6;
      "Mod+7".action = focus-workspace 7;
      "Mod+8".action = focus-workspace 8;
      "Mod+9".action = focus-workspace 9;
      "Mod+0".action = focus-workspace 10;
      "Mod+Shift+1".action.move-column-to-workspace = 1;
      "Mod+Shift+2".action.move-column-to-workspace = 2;
      "Mod+Shift+3".action.move-column-to-workspace = 3;
      "Mod+Shift+4".action.move-column-to-workspace = 4;
      "Mod+Shift+5".action.move-column-to-workspace = 5;
      "Mod+Shift+6".action.move-column-to-workspace = 6;
      "Mod+Shift+7".action.move-column-to-workspace = 7;
      "Mod+Shift+8".action.move-column-to-workspace = 8;
      "Mod+Shift+9".action.move-column-to-workspace = 9;
      "Mod+Shift+0".action.move-column-to-workspace = 10;

      # Media / brightness — work even while locked
      "XF86AudioRaiseVolume" = {
        action = spawn "wpctl" "set-volume" "-l" "1" "@DEFAULT_AUDIO_SINK@" "5%+";
        allow-when-locked = true;
      };
      "XF86AudioLowerVolume" = {
        action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-";
        allow-when-locked = true;
      };
      "XF86AudioMute" = {
        action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
        allow-when-locked = true;
      };
      "XF86AudioMicMute" = {
        action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
        allow-when-locked = true;
      };
      "XF86MonBrightnessUp" = {
        action = spawn "brightnessctl" "-e4" "-n2" "set" "5%+";
        allow-when-locked = true;
      };
      "XF86MonBrightnessDown" = {
        action = spawn "brightnessctl" "-e4" "-n2" "set" "5%-";
        allow-when-locked = true;
      };
    };

    # ── Window rules ──
    window-rules = [
      # Match Hyprland's rounded corners.
      {
        geometry-corner-radius = {
          top-left = 10.0;
          top-right = 10.0;
          bottom-left = 10.0;
          bottom-right = 10.0;
        };
        clip-to-geometry = true;
      }
      # copenguin chat overlay — float + pin equivalent
      {
        matches = [ { app-id = "^copenguin-chat$"; } ];
        open-floating = true;
      }
    ];
  };
}
