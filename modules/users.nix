{ pkgs, ... }:
{
  users.users.eriskii = {
    isNormalUser = true;
    description = "eriskii";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "render" "dialout" ];
    shell = pkgs.zsh;
    # Set password after first boot:  passwd
  };
  programs.zsh.enable = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
  };
}
