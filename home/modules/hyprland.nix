{ ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;   # fires graphical-session.target so DMS service starts
    xwayland.enable = true;

    settings = {
      # ── Monitors ──
      # Match by EDID description, not connector name — DRM connector indices
      # shift between boots (your monitors have shown up as HDMI-A-3 / DP-4 and
      # HDMI-A-1 / DP-2 on different boots), which broke 144 Hz on cold start.
      monitor = [
        "desc:Lenovo Group Limited L24q-20 U5P0MPCL, 2560x1440@59.95, 0x0, 1"
        "desc:Guangxi Century Innovation Display Electronics Co. Ltd 27M2V 0000000000000, 3840x2160@144, 2560x0, 1.5"
      ];

      # ── Variables ──
      "$mainMod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManager" = "thunar";
      "$menu" = "dms ipc call spotlight toggle";

      # ── Cursor (env) ──
      env = [
        "XCURSOR_THEME,oreo_white_cursors"
        "XCURSOR_SIZE,28"
        "HYPRCURSOR_THEME,oreo_white_cursors"
        "HYPRCURSOR_SIZE,28"
      ];

      # ── Autostart ──
      # NB: dms is started by its systemd user service via graphical-session.target;
      # don't double-launch it here.
      exec-once = [
        "gnome-keyring-daemon --start --components=secrets"
        "hyprctl setcursor oreo_white_cursors 28"
        "gsettings set org.gnome.desktop.interface cursor-theme 'oreo_white_cursors'"
        "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'"
        "gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'"
        "systemctl --user enable --now hyprpolkitagent.service"
      ];

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0.3;
        scroll_factor = 1.0;
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
          clickfinger_behavior = true;
          disable_while_typing = false;
          drag_lock = true;
          scroll_factor = 0.3;
        };
      };

      general = {
        gaps_in = 3;
        gaps_out = 5;
        border_size = 2;
        "col.active_border" = "rgba(193,193,255,1)";
        "col.inactive_border" = "rgba(919191aa)";
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
        shadow = {
          enabled = true;
          range = 30;
          render_power = 3;
          color = "rgba(00000044)";
          offset = "0 5";
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "wind, 0.05, 0.9, 0.1, 1.00"
          "winIn, 0.1, 1.1, 0.1, 1.0"
          "winOut, 0.3, -0.3, 0, 1"
          "liner, 1, 1, 1, 1"
        ];
        animation = [
          "windows, 1, 6, wind, slide"
          "windowsIn, 1, 6, winIn, slide"
          "windowsOut, 1, 5, winOut, slide"
          "windowsMove, 1, 5, wind, slide"
          "border, 1, 1, liner"
          "borderangle, 1, 30, liner, loop"
          "fade, 1, 10, default"
          "workspaces, 1, 5, wind"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master.new_status = "master";

      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = false;
      };

      cursor.no_hardware_cursors = 2;
      xwayland.force_zero_scaling = true;

      # ── Touchpad gestures ──
      # Hyprland 0.49+ declares the binding itself via `gesture =`; the
      # `gestures { }` block now only carries tuning knobs. `use_r = true`
      # walks relative workspaces (r+1/r-1) so swipes stay on the current
      # monitor's workspace set instead of crossing to the other display.
      gestures = {
        workspace_swipe_distance = 500;          # px of finger travel to commit (was 300)
        workspace_swipe_invert = true;           # natural-scroll direction
        workspace_swipe_min_speed_to_force = 60; # speed needed for a flick to commit early (was 30)
        workspace_swipe_cancel_ratio = 0.5;
        # Hyprland 0.54's WorkspaceSwipeGesture::begin() refuses to start when the
        # current monitor only has one workspace AND this flag is false — so the
        # swipe silently does nothing. Setting true lets the swipe extend into a
        # newly-created workspace at the edge.
        workspace_swipe_create_new = true;
        workspace_swipe_forever = false;
        workspace_swipe_use_r = true;            # per-monitor (relative) workspaces
      };

      # 3-finger horizontal swipe → cycle workspaces.
      gesture = [
        "3, horizontal, workspace"
      ];

      # ── Keybinds ──
      bind = [
        "$mainMod, space, exec, $menu"
        "$mainMod, Q, exec, $terminal"
        "$mainMod, C, killactive,"
        "$mainMod, V, togglefloating,"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, T, exec, kitty btop"
        "$mainMod, S, exec, hyprshot --freeze -m region"
        "$mainMod, J, layoutmsg, togglesplit"
        "$mainMod, L, exec, hyprlock"
        "$mainMod SHIFT, F, fullscreen,"
        "$mainMod, Escape, exec, dms ipc call powermenu toggle"
        "$mainMod SHIFT, C, exec, hyprpicker -a"
        "$mainMod SHIFT, W, exec, dms ipc call settings toggle"

        # Move focus
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # Move windows
        "$mainMod SHIFT, left, movewindow, l"
        "$mainMod SHIFT, right, movewindow, r"
        "$mainMod SHIFT, up, movewindow, u"
        "$mainMod SHIFT, down, movewindow, d"

        # Workspaces 1-10
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];

      windowrule = [
        "no_focus on, match:class ^$, match:title ^$, match:xwayland true, match:float true, match:fullscreen false, match:pin false"
        # copenguin tweaks
        "no_anim on, match:title ^(coPenguin Overlay)$"
        "rounding 0, match:title ^(coPenguin Overlay)$"
        "pin on, match:class copenguin-chat"
        "float on, match:class copenguin-chat"
      ];

      # DMS layer rules — Hyprland 0.54+ uses space-separated `match:namespace foo`
      # Multiple effects can be combined per layerrule line.
      layerrule = [
        "blur on, ignore_alpha 0.5, no_anim on, match:namespace dms"
      ];
    };
  };
}
