{ pkgs, ... }:
{
  # Tiered idle behavior:
  #   5 min  → DMS lock screen
  #   7 min  → blank displays (DPMS off)
  # No automatic suspend/hibernate — NVIDIA proprietary driver does not
  # resume reliably on this box; sleep is manual only.
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof dms-shell || dms ipc call lock lock";
        before_sleep_cmd = "dms ipc call lock lock";
        after_sleep_cmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 300;            # 5 min
          on-timeout = "dms ipc call lock lock";
        }
        {
          timeout = 420;            # 7 min
          on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
          on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
