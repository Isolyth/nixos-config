{ pkgs, ... }:
{
  # Tiered idle behavior:
  #   5 min  → DMS lock screen
  #   7 min  → blank displays (DPMS off)
  #  30 min  → suspend to RAM
  #
  # before_sleep_cmd locks via DMS so we wake on the lock screen.
  # after_sleep_cmd re-arms DPMS.
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
        {
          timeout = 1800;           # 30 min
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
