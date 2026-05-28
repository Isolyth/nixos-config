{ pkgs, lib, config, ... }:
let
  vaultDir = "${config.home.homeDirectory}/Documents/MainVault";
  obsidianDir = "${vaultDir}/.obsidian";
  fontFamily = "JetBrainsMono NF";

  appPatch = builtins.toJSON {
    monospaceFont = fontFamily;
    textFontFamily = fontFamily;
    interfaceFontFamily = fontFamily;
  };

  appearancePatch = builtins.toJSON {
    enabledCssSnippets = [ "matugen" ];
  };
in {
  # Obsidian's per-vault config lives inside the vault, and Obsidian writes to
  # these files when settings change in the UI — so we can't manage them as
  # read-only home-manager symlinks. Instead, merge our keys in at activation
  # and let Obsidian own the files between rebuilds.
  home.activation.obsidianConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "${vaultDir}" ]; then
      run mkdir -p "${obsidianDir}/snippets"

      patch_json() {
        local file="$1" patch="$2"
        if [ -s "$file" ]; then
          ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$file" <(printf '%s' "$patch") \
            > "$file.tmp" && run mv "$file.tmp" "$file"
        else
          printf '%s\n' "$patch" > "$file"
        fi
      }

      patch_json "${obsidianDir}/app.json"        '${appPatch}'
      patch_json "${obsidianDir}/appearance.json" '${appearancePatch}'
    fi
  '';
}
