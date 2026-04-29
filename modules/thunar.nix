{ pkgs, ... }:
{
  # Thunar file manager + the bits that make it actually useful:
  # - gvfs: trash, mtp/ftp/smb mounting
  # - tumbler: thumbnail generation
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
      thunar-media-tags-plugin
    ];
  };
  services.gvfs.enable = true;
  services.tumbler.enable = true;
}
