{ ... }:
{
  # btop config + themes preserved from old setup. Using `home.file` rather
  # than translating all 272 lines of btop.conf into nix attrs.
  xdg.configFile = {
    "btop/btop.conf".source = ../btop/btop.conf;
    "btop/themes/caelestia.theme".source = ../btop/themes/caelestia.theme;
    "btop/themes/catppuccin_mocha.theme".source = ../btop/themes/catppuccin_mocha.theme;
    "btop/themes/enby.theme".source = ../btop/themes/enby.theme;
    "btop/themes/Rosepine.theme".source = ../btop/themes/Rosepine.theme;
  };
}
