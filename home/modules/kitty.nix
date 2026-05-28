{ ... }:
{
  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrainsMono Nerd Font Mono";
      size = 12;
    };

    settings = {
      cursor_shape = "block";
      cursor_trail = 1;
      window_margin_width = 10;
      confirm_os_window_close = 0;
      background_opacity = "1";
      touch_scroll_multiplier = "3.0";
      wheel_scroll_multiplier = "8.0";
    };

    # DMS dynamically writes dank-theme.conf (matugen colors) and dank-tabs.conf
    # alongside this file. Including them keeps the dynamic theming intact.
    extraConfig = ''
      include dank-theme.conf
      include dank-tabs.conf
    '';
  };
}
