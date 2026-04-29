{ pkgs, ... }:
let
  matugenThemes = pkgs.fetchFromGitHub {
    owner = "InioX";
    repo = "matugen-themes";
    rev = "7d4c8b95c65827ee590c5638c172e91c731ec4e8";
    hash = "sha256-k7rC2tpkJnQQ/9kPSKZ5EFxCAyk3aTdL+ki1Ww+bhy4=";
  };
in {
  # Matugen + Vesktop integration. DMS sets `runUserMatugenTemplates=true` in
  # its settings, so it'll rerun matugen with this config on wallpaper change.
  #
  # After rebuild: in Vesktop → Vencord settings → Themes, enable
  # `midnight-discord.css`.

  xdg.configFile = {
    "matugen/templates/midnight-discord.css".source =
      "${matugenThemes}/templates/midnight-discord.css";

    "matugen/config.toml".text = ''
      # User templates appended to DMS's matugen run.
      [templates.vesktop]
      input_path = "~/.config/matugen/templates/midnight-discord.css"
      output_path = "~/.config/vesktop/themes/midnight-discord.css"
    '';
  };
}
