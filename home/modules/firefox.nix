{ ... }:
{
  home.file.".config/mozilla/firefox/7k4p2hbt.default/user.js".text = ''
    user_pref("mousewheel.system_scroll_override.enabled", true);
    user_pref("mousewheel.default.delta_multiplier_x", 300);
    user_pref("mousewheel.default.delta_multiplier_y", 300);
    user_pref("mousewheel.default.delta_multiplier_z", 300);
  '';
}
